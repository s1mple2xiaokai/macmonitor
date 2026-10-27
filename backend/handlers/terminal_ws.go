package handlers

import (
	"crypto/subtle"
	"encoding/base64"
	"net/http"
	"os"
	"strings"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"github.com/rs/zerolog/log"
)

const (
	terminalWSWriteWait  = 10 * time.Second
	terminalWSPongWait   = 60 * time.Second
	terminalWSPingPeriod = (terminalWSPongWait * 9) / 10
	terminalWSReadLimit  = 64 * 1024
)

var terminalWSUpgrader = websocket.Upgrader{
	ReadBufferSize:  4096,
	WriteBufferSize: 4096,
	CheckOrigin: func(r *http.Request) bool {
		// Allow all origins for development
		return true
	},
}

var configuredTerminalToken string

func SetTerminalToken(token string) {
	configuredTerminalToken = strings.TrimSpace(token)
}

func TerminalWebSocketHandler(w http.ResponseWriter, r *http.Request) {
	applyTerminalWebSocketHeaders(w)

	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	if r.Method != http.MethodGet {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	if !websocket.IsWebSocketUpgrade(r) {
		http.Error(w, "websocket upgrade required", http.StatusBadRequest)
		return
	}

	if ok, reason := authorizedTerminalRequest(r); !ok {
		status := http.StatusUnauthorized
		if reason == "terminal token is not configured" {
			status = http.StatusServiceUnavailable
		}
		http.Error(w, reason, status)
		return
	}

	conn, err := terminalWSUpgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Debug().Err(err).Msg("terminal websocket upgrade failed")
		return
	}
	defer conn.Close()
	_ = conn.UnderlyingConn().SetDeadline(time.Time{})

	session, err := newTerminalSession()
	if err != nil {
		log.Error().Err(err).Msg("failed to create terminal websocket session")
		_ = conn.WriteControl(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseInternalServerErr, "session create failed"), time.Now().Add(terminalWSWriteWait))
		return
	}

	terminalSessions.Lock()
	terminalSessions.items[session.id] = session
	terminalSessions.Unlock()
	go session.waitAndCleanup()
	defer session.close()

	updates := make(chan string, 256)
	session.addListener(updates)
	defer session.removeListener(updates)

	done := make(chan struct{})
	var doneOnce sync.Once
	closeDone := func() {
		doneOnce.Do(func() {
			close(done)
		})
	}
	defer closeDone()

	conn.SetReadLimit(terminalWSReadLimit)
	_ = conn.SetReadDeadline(time.Now().Add(terminalWSPongWait))
	conn.SetPongHandler(func(string) error {
		return conn.SetReadDeadline(time.Now().Add(terminalWSPongWait))
	})
	conn.SetPingHandler(func(appData string) error {
		_ = conn.SetReadDeadline(time.Now().Add(terminalWSPongWait))
		deadline := time.Now().Add(terminalWSWriteWait)
		return conn.WriteControl(websocket.PongMessage, []byte(appData), deadline)
	})

	streamDone := make(chan struct{})
	go func() {
		ticker := time.NewTicker(terminalWSPingPeriod)
		defer ticker.Stop()
		defer close(streamDone)

		for {
			select {
			case <-done:
				return
			case <-session.done:
				_ = conn.WriteControl(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, "terminal closed"), time.Now().Add(terminalWSWriteWait))
				return
			case msg, ok := <-updates:
				if !ok {
					return
				}
				payload, decodeErr := base64.StdEncoding.DecodeString(msg)
				if decodeErr != nil {
					log.Debug().Err(decodeErr).Str("session", session.id).Msg("failed to decode terminal output")
					continue
				}
				if err := writeWSMessage(conn, websocket.BinaryMessage, payload); err != nil {
					log.Debug().Err(err).Str("session", session.id).Msg("failed to stream terminal output")
					return
				}
			case <-ticker.C:
				if err := writeWSMessage(conn, websocket.PingMessage, []byte("ping")); err != nil {
					log.Debug().Err(err).Str("session", session.id).Msg("terminal websocket heartbeat failed")
					return
				}
			}
		}
	}()

	for {
		msgType, data, err := conn.ReadMessage()
		if err != nil {
			if !websocket.IsCloseError(err, websocket.CloseNormalClosure, websocket.CloseGoingAway) {
				log.Debug().Err(err).Str("session", session.id).Msg("terminal websocket read failed")
			}
			break
		}

		if msgType != websocket.TextMessage && msgType != websocket.BinaryMessage {
			continue
		}
		if len(data) == 0 {
			continue
		}

		if err := session.writeInput(string(data)); err != nil {
			log.Debug().Err(err).Str("session", session.id).Msg("failed to write terminal input")
			_ = conn.WriteControl(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseInternalServerErr, "failed to write input"), time.Now().Add(terminalWSWriteWait))
			break
		}
	}

	closeDone()
	<-streamDone
}

func terminalWebSocketHandler(w http.ResponseWriter, r *http.Request) {
	TerminalWebSocketHandler(w, r)
}

func writeWSMessage(conn *websocket.Conn, msgType int, payload []byte) error {
	if err := conn.SetWriteDeadline(time.Now().Add(terminalWSWriteWait)); err != nil {
		return err
	}
	return conn.WriteMessage(msgType, payload)
}

func authorizedTerminalRequest(r *http.Request) (bool, string) {
	expected := expectedTerminalToken()
	if expected == "" {
		return false, "terminal token is not configured"
	}

	provided := terminalTokenFromRequest(r)
	if provided == "" {
		return false, "missing terminal token"
	}

	if subtle.ConstantTimeCompare([]byte(provided), []byte(expected)) != 1 {
		return false, "invalid terminal token"
	}

	return true, ""
}

func expectedTerminalToken() string {
	expected := strings.TrimSpace(configuredTerminalToken)
	if expected == "" {
		expected = strings.TrimSpace(os.Getenv("WEBTERM_TOKEN"))
	}
	return expected
}

func terminalTokenFromRequest(r *http.Request) string {
	// Check Authorization header (Bearer token)
	if bearer := strings.TrimSpace(r.Header.Get("Authorization")); strings.HasPrefix(strings.ToLower(bearer), "bearer ") {
		return strings.TrimSpace(bearer[7:])
	}
	// Check X-Terminal-Token header
	if token := strings.TrimSpace(r.Header.Get("X-Terminal-Token")); token != "" {
		return token
	}
	// Check query parameter
	if token := strings.TrimSpace(r.URL.Query().Get("token")); token != "" {
		return token
	}
	// Optional fallback for clients that pass token via subprotocol, e.g. "token.<value>" or "bearer.<value>"
	for _, part := range strings.Split(r.Header.Get("Sec-WebSocket-Protocol"), ",") {
		protocol := strings.TrimSpace(part)
		switch {
		case strings.HasPrefix(strings.ToLower(protocol), "token."):
			return strings.TrimSpace(protocol[len("token."):])
		case strings.HasPrefix(strings.ToLower(protocol), "bearer."):
			return strings.TrimSpace(protocol[len("bearer."):])
		}
	}
	return ""
}

func applyTerminalWebSocketHeaders(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Terminal-Token, Sec-WebSocket-Protocol")
}
