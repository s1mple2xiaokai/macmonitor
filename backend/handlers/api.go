package handlers

import (
	"encoding/json"
	"net/http"
	"time"

	"macmonitor/collectors"

	"github.com/gorilla/mux"
	"github.com/rs/zerolog/log"
)

func RegisterAPIRoutes(r *mux.Router) {
	api := r.PathPrefix("/api").Subrouter()
	api.Use(loggingMiddleware)
	api.Use(corsMiddleware)

	api.HandleFunc("/stats", getAllStatsHandler).Methods(http.MethodGet, http.MethodOptions)
	api.HandleFunc("/cpu", getCPUStatsHandler).Methods(http.MethodGet, http.MethodOptions)
	api.HandleFunc("/memory", getMemoryStatsHandler).Methods(http.MethodGet, http.MethodOptions)
	api.HandleFunc("/disk", getDiskStatsHandler).Methods(http.MethodGet, http.MethodOptions)
	api.HandleFunc("/network", getNetworkStatsHandler).Methods(http.MethodGet, http.MethodOptions)
	api.HandleFunc("/processes", getProcessStatsHandler).Methods(http.MethodGet, http.MethodOptions)
	api.HandleFunc("/apps", getAppStatsHandler).Methods(http.MethodGet, http.MethodOptions)
}

func getAllStatsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	stats, err := collectors.GetAllStats()
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

func getCPUStatsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	stats, err := collectors.GetCPUStats()
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

func getMemoryStatsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	stats, err := collectors.GetMemoryStats()
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

func getDiskStatsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	stats, err := collectors.GetDiskStats()
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

func getNetworkStatsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	stats, err := collectors.GetNetworkStats()
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

func getProcessStatsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	stats, err := collectors.GetProcessStats()
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

func getAppStatsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	stats, err := collectors.GetAppStats()
	if err != nil {
		writeJSONError(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, stats)
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		log.Error().Err(err).Int("status", status).Msg("failed to write json response")
	}
}

func writeJSONError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Info().
			Str("method", r.Method).
			Str("path", r.URL.Path).
			Str("remoteAddr", r.RemoteAddr).
			Dur("duration", time.Since(start)).
			Msg("api request")
	})
}
