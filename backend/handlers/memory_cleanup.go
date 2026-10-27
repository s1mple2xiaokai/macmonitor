package handlers

import (
	"context"
	"errors"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/rs/zerolog/log"
)

type memoryCleanupResponse struct {
	Success   bool   `json:"success"`
	Message   string `json:"message"`
	Command   string `json:"command"`
	Output    string `json:"output,omitempty"`
	Timestamp string `json:"timestamp"`
}

func clearMemoryCacheHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	commandText, cmd, cancel := newMemoryCleanupCommand(r.Context())
	defer cancel()
	startedAt := time.Now().UTC()
	output, err := cmd.CombinedOutput()
	duration := time.Since(startedAt)
	outputText := strings.TrimSpace(string(output))

	if err != nil {
		status, message := mapMemoryCleanupError(err, outputText)
		log.Error().
			Err(err).
			Str("command", commandText).
			Str("output", outputText).
			Dur("duration", duration).
			Msg("memory cleanup failed")

		writeJSON(w, status, memoryCleanupResponse{
			Success:   false,
			Message:   message,
			Command:   commandText,
			Output:    outputText,
			Timestamp: startedAt.Format(time.RFC3339),
		})
		return
	}

	message := "memory cache cleanup command completed"
	if outputText == "" {
		message = "memory cache cleanup completed"
	}

	log.Info().
		Str("command", commandText).
		Str("output", outputText).
		Dur("duration", duration).
		Msg("memory cleanup completed")

	writeJSON(w, http.StatusOK, memoryCleanupResponse{
		Success:   true,
		Message:   message,
		Command:   commandText,
		Output:    outputText,
		Timestamp: startedAt.Format(time.RFC3339),
	})
}

func newMemoryCleanupCommand(parent context.Context) (string, *exec.Cmd, context.CancelFunc) {
	ctx, cancel := context.WithTimeout(parent, 30*time.Second)
	override := strings.TrimSpace(os.Getenv("MEMORY_CLEANUP_COMMAND"))
	if override != "" {
		return override, exec.CommandContext(ctx, "/bin/sh", "-lc", override), cancel
	}
	// 使用 AppleScript 弹出管理员授权对话框
	script := `do shell script "purge" with administrator privileges`
	return "purge (AppleScript)", exec.CommandContext(ctx, "osascript", "-e", script), cancel
}

func mapMemoryCleanupError(err error, output string) (int, string) {
	if errors.Is(err, context.DeadlineExceeded) {
		return http.StatusGatewayTimeout, "memory cleanup timed out"
	}

	combined := strings.ToLower(strings.TrimSpace(err.Error() + " " + output))
	if errors.Is(err, exec.ErrNotFound) || strings.Contains(combined, "executable file not found") || strings.Contains(combined, "no such file or directory") {
		return http.StatusNotImplemented, "memory cleanup command is unavailable on this host"
	}

	if strings.Contains(combined, "operation not permitted") ||
		strings.Contains(combined, "permission denied") ||
		strings.Contains(combined, "must be root") ||
		strings.Contains(combined, "not permitted") {
		return http.StatusForbidden, "memory cleanup requires root privileges"
	}

	return http.StatusInternalServerError, "failed to clear memory cache"
}
