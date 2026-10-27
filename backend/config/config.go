package config

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"gopkg.in/yaml.v3"
)

type Config struct {
	Port            string
	RefreshInterval time.Duration
	TerminalToken   string
	LogLevel        string
	LogFormat       string
	LogOutput       string
	LogFilePath     string
}

type fileConfig struct {
	Port                   int    `yaml:"port"`
	RefreshIntervalSeconds int    `yaml:"refreshIntervalSeconds"`
	TerminalToken          string `yaml:"terminalToken"`
	Logging                struct {
		Level    string `yaml:"level"`
		Format   string `yaml:"format"`
		Output   string `yaml:"output"`
		FilePath string `yaml:"filePath"`
	} `yaml:"logging"`
}

func Load() (Config, error) {
	cfg := Config{
		Port:            "8080",
		RefreshInterval: 2 * time.Second,
		TerminalToken:   "",
		LogLevel:        "info",
		LogFormat:       "json",
		LogOutput:       "stdout",
		LogFilePath:     "./logs/macmonitor.log",
	}

	if err := applyYAMLConfig("config.yaml", &cfg); err != nil {
		return cfg, err
	}

	var validationErr error

	if raw := strings.TrimSpace(os.Getenv("PORT")); raw != "" {
		if err := validatePort(raw); err != nil {
			validationErr = errors.Join(validationErr, fmt.Errorf("invalid PORT env: %w", err))
		} else {
			cfg.Port = raw
		}
	}

	if raw := strings.TrimSpace(os.Getenv("REFRESH_INTERVAL_SECONDS")); raw != "" {
		seconds, err := strconv.Atoi(raw)
		if err != nil || seconds <= 0 {
			validationErr = errors.Join(validationErr, fmt.Errorf("invalid REFRESH_INTERVAL_SECONDS env: %q", raw))
		} else {
			cfg.RefreshInterval = time.Duration(seconds) * time.Second
		}
	}
	if raw := strings.TrimSpace(os.Getenv("WEBTERM_TOKEN")); raw != "" {
		cfg.TerminalToken = raw
	}

	if raw := strings.TrimSpace(os.Getenv("LOG_LEVEL")); raw != "" {
		cfg.LogLevel = strings.ToLower(raw)
	}
	if raw := strings.TrimSpace(os.Getenv("LOG_OUTPUT")); raw != "" {
		cfg.LogOutput = strings.ToLower(raw)
	}
	if raw := strings.TrimSpace(os.Getenv("LOG_FILE_PATH")); raw != "" {
		cfg.LogFilePath = raw
	}

	if err := validatePort(cfg.Port); err != nil {
		validationErr = errors.Join(validationErr, fmt.Errorf("invalid port value: %w", err))
		cfg.Port = "8080"
	}
	if cfg.RefreshInterval <= 0 {
		validationErr = errors.Join(validationErr, fmt.Errorf("refresh interval must be > 0"))
		cfg.RefreshInterval = 2 * time.Second
	}

	switch cfg.LogLevel {
	case "debug", "info", "warn", "error":
	default:
		validationErr = errors.Join(validationErr, fmt.Errorf("invalid log level %q", cfg.LogLevel))
		cfg.LogLevel = "info"
	}

	switch cfg.LogOutput {
	case "stdout", "file":
	default:
		validationErr = errors.Join(validationErr, fmt.Errorf("invalid log output %q", cfg.LogOutput))
		cfg.LogOutput = "stdout"
	}

	if cfg.LogOutput == "file" {
		if strings.TrimSpace(cfg.LogFilePath) == "" {
			validationErr = errors.Join(validationErr, fmt.Errorf("log file path is required when output=file"))
			cfg.LogFilePath = "./logs/macmonitor.log"
		}
	}

	return cfg, validationErr
}

func applyYAMLConfig(path string, cfg *Config) error {
	data, err := os.ReadFile(path)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return nil
		}
		return fmt.Errorf("read config file %q: %w", path, err)
	}

	var fc fileConfig
	if err := yaml.Unmarshal(data, &fc); err != nil {
		return fmt.Errorf("parse config file %q: %w", path, err)
	}

	if fc.Port > 0 {
		cfg.Port = strconv.Itoa(fc.Port)
	}
	if fc.RefreshIntervalSeconds > 0 {
		cfg.RefreshInterval = time.Duration(fc.RefreshIntervalSeconds) * time.Second
	}
	if strings.TrimSpace(fc.TerminalToken) != "" {
		cfg.TerminalToken = strings.TrimSpace(fc.TerminalToken)
	}
	if strings.TrimSpace(fc.Logging.Level) != "" {
		cfg.LogLevel = strings.ToLower(strings.TrimSpace(fc.Logging.Level))
	}
	if strings.TrimSpace(fc.Logging.Format) != "" {
		cfg.LogFormat = strings.ToLower(strings.TrimSpace(fc.Logging.Format))
	}
	if strings.TrimSpace(fc.Logging.Output) != "" {
		cfg.LogOutput = strings.ToLower(strings.TrimSpace(fc.Logging.Output))
	}
	if strings.TrimSpace(fc.Logging.FilePath) != "" {
		cfg.LogFilePath = filepath.Clean(fc.Logging.FilePath)
	}

	return nil
}

func validatePort(port string) error {
	v, err := strconv.Atoi(port)
	if err != nil {
		return fmt.Errorf("must be numeric: %w", err)
	}
	if v < 1 || v > 65535 {
		return fmt.Errorf("out of range: %d", v)
	}
	return nil
}
