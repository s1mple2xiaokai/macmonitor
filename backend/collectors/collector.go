package collectors

import (
	"context"
	"time"

	"macmonitor/models"
)

func GetAllStats() (models.SystemStats, error) {
	// 添加 5 秒超时
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	return GetAllStatsWithContext(ctx)
}

func GetAllStatsWithContext(ctx context.Context) (models.SystemStats, error) {
	stats := models.SystemStats{
		Timestamp: time.Now().UTC(),
		CPU:       models.CPUStats{ModelName: "unknown"},
		Disk:      make([]models.DiskStats, 0),
		Network:   make([]models.NetworkStats, 0),
		Processes: make([]models.ProcessInfo, 0),
		Apps:      make([]models.AppInfo, 0),
	}

	if err := ctx.Err(); err != nil {
		return stats, err
	}

	cpuStats, err := GetCPUStats()
	if err == nil {
		stats.CPU = cpuStats
	}

	if err := ctx.Err(); err != nil {
		return stats, err
	}

	memoryStats, err := GetMemoryStats()
	if err == nil {
		stats.Memory = memoryStats
	}

	if err := ctx.Err(); err != nil {
		return stats, err
	}

	diskStats, err := GetDiskStats()
	if err == nil {
		stats.Disk = diskStats
	}

	if err := ctx.Err(); err != nil {
		return stats, err
	}

	networkStats, err := GetNetworkStats()
	if err == nil {
		stats.Network = networkStats
	}

	if err := ctx.Err(); err != nil {
		return stats, err
	}

	processStats, err := GetProcessStats()
	if err == nil {
		stats.Processes = processStats
	}

	if err := ctx.Err(); err != nil {
		return stats, err
	}

	appStats, err := GetAppStats()
	if err == nil {
		stats.Apps = appStats
	}

	return stats, nil
}
