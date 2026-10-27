package handlers

import (
	"bufio"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"sync"

	"github.com/gorilla/mux"
	"github.com/rs/zerolog/log"
)

var (
	terminalPageTemplate = template.Must(template.New("terminal").Parse(`<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>MacMonitor Web Terminal</title>
  <style>
    html, body { margin: 0; height: 100%; background: #0a0f14; color: #d9e1e8; font-family: Menlo, Monaco, Consolas, monospace; }
    .layout { display: grid; grid-template-rows: auto 1fr auto; height: 100%; }
    .topbar { padding: 8px 12px; border-bottom: 1px solid #1f2b38; display: flex; gap: 8px; align-items: center; flex-wrap: wrap; }
    .topbar button { background: #1a2531; color: #d9e1e8; border: 1px solid #2a3a4a; border-radius: 6px; padding: 6px 10px; }
    .topbar .status { font: 12px -apple-system, BlinkMacSystemFont, sans-serif; color: #90a2b5; }
    #screen { white-space: pre-wrap; overflow: auto; margin: 0; padding: 10px; }
    .inputbar { border-top: 1px solid #1f2b38; padding: 8px; }
    #kb { width: 100%; padding: 10px; border-radius: 8px; border: 1px solid #2a3a4a; background: #101720; color: #d9e1e8; font-size: 16px; }
  </style>
</head>
<body>
  <div class="layout">
    <div class="topbar">
      <button id="connectBtn">Connect</button>
      <button id="ctrlCBtn">Ctrl+C</button>
      <button id="clearBtn">Clear</button>
      <button id="closeBtn">Close Session</button>
      <span class="status" id="status">idle</span>
    </div>
    <pre id="screen"></pre>
    <div class="inputbar">
      <input id="kb" type="text" autocomplete="off" autocapitalize="off" spellcheck="false" placeholder="Type command, Enter to run. Mobile keyboard supported." />
    </div>
  </div>

<script>
const params = new URLSearchParams(location.search);
const token = params.get('token') || '{{.Token}}';
if (!token) {
  alert('Missing token. Open /terminal?token=YOUR_TOKEN');
  throw new Error('missing token');
}

const screen = document.getElementById('screen');
const statusEl = document.getElementById('status');
const kb = document.getElementById('kb');
let sessionId = '';
let stream = null;

function setStatus(text) { statusEl.textContent = text; }
function append(text) {
  screen.textContent += text;
  screen.scrollTop = screen.scrollHeight;
}

async function openSession() {
  if (sessionId) return;
  const r = await fetch('/terminal/session?token=' + encodeURIComponent(token), { method: 'POST' });
  if (!r.ok) throw new Error('session create failed: ' + r.status);
  const data = await r.json();
  sessionId = data.sessionId;

  stream = new EventSource('/terminal/stream/' + encodeURIComponent(sessionId) + '?token=' + encodeURIComponent(token));
  stream.onmessage = (evt) => {
    try {
      const decoded = atob(evt.data);
      append(decoded);
    } catch (e) {
      append('\n[decode error]\n');
    }
  };
  stream.onerror = () => setStatus('stream disconnected');
  setStatus('connected');
}

async function sendInput(data) {
  if (!sessionId) return;
  await fetch('/terminal/input/' + encodeURIComponent(sessionId) + '?token=' + encodeURIComponent(token), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ data })
  });
}

async function closeSession() {
  if (!sessionId) return;
  await fetch('/terminal/close/' + encodeURIComponent(sessionId) + '?token=' + encodeURIComponent(token), { method: 'POST' });
  if (stream) stream.close();
  stream = null;
  sessionId = '';
  setStatus('closed');
}

document.getElementById('connectBtn').addEventListener('click', async () => {
  try {
    await openSession();
    kb.focus();
  } catch (e) {
    setStatus(String(e));
  }
});

document.getElementById('ctrlCBtn').addEventListener('click', () => sendInput('\u0003'));
document.getElementById('clearBtn').addEventListener('click', () => { screen.textContent = ''; kb.focus(); });
document.getElementById('closeBtn').addEventListener('click', () => closeSession());

kb.addEventListener('keydown', async (e) => {
  if (!sessionId) return;
  if (e.key === 'Enter') {
    e.preventDefault();
    await sendInput((kb.value || '') + '\n');
    kb.value = '';
    return;
  }

  if (e.key === 'Tab') {
    e.preventDefault();
    await sendInput('\t');
    return;
  }

  if (e.key === 'Backspace' && kb.value.length === 0) {
    e.preventDefault();
    await sendInput('\u007f');
    return;
  }

  if (e.key === 'ArrowUp') { e.preventDefault(); await sendInput('\u001b[A'); return; }
  if (e.key === 'ArrowDown') { e.preventDefault(); await sendInput('\u001b[B'); return; }
  if (e.key === 'ArrowRight') { e.preventDefault(); await sendInput('\u001b[C'); return; }
  if (e.key === 'ArrowLeft') { e.preventDefault(); await sendInput('\u001b[D'); return; }

  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'c') {
    e.preventDefault();
    await sendInput('\u0003');
  }
});

kb.addEventListener('input', async () => {
  if (!sessionId) return;
  if (!kb.value) return;
  await sendInput(kb.value);
  kb.value = '';
});

window.addEventListener('beforeunload', () => {
  if (stream) stream.close();
});
</script>
</body>
</html>`))

	terminalSessions = struct {
		sync.RWMutex
		items map[string]*terminalSession
	}{items: make(map[string]*terminalSession)}
)

type terminalSession struct {
	id        string
	cmd       *exec.Cmd
	stdin     io.WriteCloser
	done      chan struct{}
	mu        sync.Mutex
	closed    bool
	listeners map[chan string]struct{}
}

type terminalInputRequest struct {
	Data string `json:"data"`
}

type terminalSessionResponse struct {
	SessionID string `json:"sessionId"`
}

func RegisterTerminalRoutes(r *mux.Router) {
	r.HandleFunc("/terminal", terminalPageHandler).Methods(http.MethodGet)
	r.HandleFunc("/terminal/", terminalPageHandler).Methods(http.MethodGet)
	r.HandleFunc("/terminal/session", terminalCreateSessionHandler).Methods(http.MethodPost)
	r.HandleFunc("/terminal/stream/{id}", terminalStreamHandler).Methods(http.MethodGet)
	r.HandleFunc("/terminal/input/{id}", terminalInputHandler).Methods(http.MethodPost)
	r.HandleFunc("/terminal/close/{id}", terminalCloseHandler).Methods(http.MethodPost)
}

func terminalPageHandler(w http.ResponseWriter, r *http.Request) {
	ok, reason := authorizedTerminalRequest(r)
	if !ok {
		status := http.StatusUnauthorized
		if reason == "terminal token is not configured" {
			status = http.StatusServiceUnavailable
		}
		http.Error(w, reason, status)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := terminalPageTemplate.Execute(w, struct{ Token string }{Token: getTokenFromRequest(r)}); err != nil {
		log.Error().Err(err).Msg("failed to render terminal page")
	}
}

func terminalCreateSessionHandler(w http.ResponseWriter, r *http.Request) {
	if ok, reason := authorizedTerminalRequest(r); !ok {
		http.Error(w, reason, http.StatusUnauthorized)
		return
	}

	session, err := newTerminalSession()
	if err != nil {
		log.Error().Err(err).Msg("failed to create terminal session")
		writeJSONError(w, http.StatusInternalServerError, "failed to create terminal session")
		return
	}

	terminalSessions.Lock()
	terminalSessions.items[session.id] = session
	terminalSessions.Unlock()

	go session.waitAndCleanup()
	writeJSON(w, http.StatusOK, terminalSessionResponse{SessionID: session.id})
}

func terminalStreamHandler(w http.ResponseWriter, r *http.Request) {
	if ok, reason := authorizedTerminalRequest(r); !ok {
		http.Error(w, reason, http.StatusUnauthorized)
		return
	}

	id := mux.Vars(r)["id"]
	session := findTerminalSession(id)
	if session == nil {
		http.Error(w, "session not found", http.StatusNotFound)
		return
	}

	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming unsupported", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")

	updates := make(chan string, 128)
	session.addListener(updates)
	defer session.removeListener(updates)

	fmt.Fprint(w, ": connected\n\n")
	flusher.Flush()

	for {
		select {
		case <-r.Context().Done():
			return
		case <-session.done:
			fmt.Fprint(w, "event: done\ndata: \n\n")
			flusher.Flush()
			return
		case msg, ok := <-updates:
			if !ok {
				return
			}
			fmt.Fprintf(w, "data: %s\n\n", msg)
			flusher.Flush()
		}
	}
}

func terminalInputHandler(w http.ResponseWriter, r *http.Request) {
	if ok, reason := authorizedTerminalRequest(r); !ok {
		http.Error(w, reason, http.StatusUnauthorized)
		return
	}

	id := mux.Vars(r)["id"]
	session := findTerminalSession(id)
	if session == nil {
		http.Error(w, "session not found", http.StatusNotFound)
		return
	}

	var req terminalInputRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request", http.StatusBadRequest)
		return
	}

	if req.Data == "" {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	if err := session.writeInput(req.Data); err != nil {
		http.Error(w, "failed to write input", http.StatusBadRequest)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

func terminalCloseHandler(w http.ResponseWriter, r *http.Request) {
	if ok, reason := authorizedTerminalRequest(r); !ok {
		http.Error(w, reason, http.StatusUnauthorized)
		return
	}

	id := mux.Vars(r)["id"]
	session := findTerminalSession(id)
	if session == nil {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	session.close()
	w.WriteHeader(http.StatusNoContent)
}

func newTerminalSession() (*terminalSession, error) {
	shell := strings.TrimSpace(os.Getenv("WEBTERM_SHELL"))
	if shell == "" {
		shell = strings.TrimSpace(os.Getenv("SHELL"))
	}
	if shell == "" {
		shell = "/bin/zsh"
	}

	id, err := randomID(16)
	if err != nil {
		return nil, err
	}

	cmd := exec.Command("script", "-q", "/dev/null", shell, "-l")
	stdin, err := cmd.StdinPipe()
	if err != nil {
		return nil, err
	}
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return nil, err
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return nil, err
	}
	if err := cmd.Start(); err != nil {
		return nil, err
	}

	session := &terminalSession{
		id:        id,
		cmd:       cmd,
		stdin:     stdin,
		done:      make(chan struct{}),
		listeners: make(map[chan string]struct{}),
	}

	go session.forwardOutput(stdout)
	go session.forwardOutput(stderr)

	return session, nil
}

func (s *terminalSession) forwardOutput(r io.Reader) {
	reader := bufio.NewReader(r)
	buf := make([]byte, 4096)
	for {
		n, err := reader.Read(buf)
		if n > 0 {
			encoded := base64.StdEncoding.EncodeToString(buf[:n])
			s.broadcast(encoded)
		}
		if err != nil {
			if err != io.EOF {
				log.Debug().Err(err).Str("session", s.id).Msg("terminal output stream closed")
			}
			return
		}
	}
}

func (s *terminalSession) writeInput(data string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.closed {
		return fmt.Errorf("session closed")
	}
	_, err := io.WriteString(s.stdin, data)
	return err
}

func (s *terminalSession) addListener(ch chan string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.listeners[ch] = struct{}{}
}

func (s *terminalSession) removeListener(ch chan string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	delete(s.listeners, ch)
	close(ch)
}

func (s *terminalSession) broadcast(message string) {
	s.mu.Lock()
	defer s.mu.Unlock()
	for ch := range s.listeners {
		select {
		case ch <- message:
		default:
		}
	}
}

func (s *terminalSession) close() {
	s.mu.Lock()
	if s.closed {
		s.mu.Unlock()
		return
	}
	s.closed = true
	s.mu.Unlock()

	if s.cmd.Process != nil {
		_ = s.cmd.Process.Kill()
	}
}

func (s *terminalSession) waitAndCleanup() {
	_ = s.cmd.Wait()

	s.mu.Lock()
	if !s.closed {
		s.closed = true
	}
	for ch := range s.listeners {
		close(ch)
		delete(s.listeners, ch)
	}
	s.mu.Unlock()

	terminalSessions.Lock()
	delete(terminalSessions.items, s.id)
	terminalSessions.Unlock()

	select {
	case <-s.done:
	default:
		close(s.done)
	}
}

func findTerminalSession(id string) *terminalSession {
	terminalSessions.RLock()
	defer terminalSessions.RUnlock()
	return terminalSessions.items[id]
}

func getTokenFromRequest(r *http.Request) string {
	return terminalTokenFromRequest(r)
}

func randomID(length int) (string, error) {
	if length <= 0 {
		length = 16
	}
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(bytes), nil
}
