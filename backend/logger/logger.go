package logger

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func Init(level, format, output, filePath string) (func() error, error) {
	parsedLevel, err := zerolog.ParseLevel(strings.ToLower(level))
	if err != nil {
		return nil, fmt.Errorf("parse log level %q: %w", level, err)
	}
	zerolog.SetGlobalLevel(parsedLevel)

	var writer io.Writer = os.Stdout
	closeFn := func() error { return nil }

	if strings.EqualFold(output, "file") {
		if strings.TrimSpace(filePath) == "" {
			return nil, fmt.Errorf("log file path is empty")
		}
		dir := filepath.Dir(filePath)
		if err := os.MkdirAll(dir, 0o755); err != nil {
			return nil, fmt.Errorf("create log directory %q: %w", dir, err)
		}
		file, err := os.OpenFile(filePath, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0o644)
		if err != nil {
			return nil, fmt.Errorf("open log file %q: %w", filePath, err)
		}
		writer = file
		closeFn = file.Close
	}

	if strings.EqualFold(format, "console") {
		writer = zerolog.ConsoleWriter{Out: writer}
	}

	log.Logger = zerolog.New(writer).With().Timestamp().Logger()
	return closeFn, nil
}
