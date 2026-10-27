package main

import (
	"encoding/json"
	"errors"
	"net/http"
	"time"

	"macmonitor/config"
	"macmonitor/handlers"
	"macmonitor/logger"

	"github.com/gorilla/mux"
	"github.com/rs/zerolog/log"
	"github.com/shirou/gopsutil/v3/host"
)

type healthResponse struct {
	Status          string `json:"status"`
	Timestamp       string `json:"timestamp"`
	RefreshInterval string `json:"refreshInterval"`
}

func main() {
	cfg, cfgErr := config.Load()
	closeLogger, logInitErr := logger.Init(cfg.LogLevel, cfg.LogFormat, cfg.LogOutput, cfg.LogFilePath)
	if logInitErr != nil {
		panic(logInitErr)
	}
	defer func() {
		if err := closeLogger(); err != nil {
			log.Error().Err(err).Msg("failed to close log output")
		}
	}()

	if cfgErr != nil {
		log.Warn().Err(cfgErr).Msg("configuration loaded with validation warnings; defaults were applied")
	}
	handlers.SetTerminalToken(cfg.TerminalToken)

	r := mux.NewRouter()
	r.HandleFunc("/api/health", healthHandler(cfg.RefreshInterval)).Methods(http.MethodGet)
	r.HandleFunc("/terminal/ws", handlers.TerminalWebSocketHandler).Methods(http.MethodGet, http.MethodOptions)
	r.HandleFunc("/terminal/ws/", handlers.TerminalWebSocketHandler).Methods(http.MethodGet, http.MethodOptions)
	r.HandleFunc("/api/terminal/ws", handlers.TerminalWebSocketHandler).Methods(http.MethodGet, http.MethodOptions)
	r.HandleFunc("/api/terminal/ws/", handlers.TerminalWebSocketHandler).Methods(http.MethodGet, http.MethodOptions)

	// 注册 API 路由
	handlers.RegisterAPIRoutes(r)
	handlers.RegisterTerminalRoutes(r)

	addr := ":" + cfg.Port

	// 添加 HTTP server 超时设置，防止 DoS
	srv := &http.Server{
		Addr:         addr,
		Handler:      r,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	log.Info().
		Str("address", addr).
		Str("logLevel", cfg.LogLevel).
		Str("logOutput", cfg.LogOutput).
		Dur("refreshInterval", cfg.RefreshInterval).
		Msg("MacMonitor server listening")

	if err := srv.ListenAndServe(); err != nil {
		if !errors.Is(err, http.ErrServerClosed) {
			log.Fatal().Err(err).Msg("server failed")
		}
	}
}

func healthHandler(refreshInterval time.Duration) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		status := "ok"
		if _, err := host.Info(); err != nil {
			status = "degraded"
		}

		resp := healthResponse{
			Status:          status,
			Timestamp:       time.Now().UTC().Format(time.RFC3339),
			RefreshInterval: refreshInterval.String(),
		}

		w.Header().Set("Content-Type", "application/json")
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			log.Error().Err(err).Msg("failed to encode health response")
		}
	}
}
