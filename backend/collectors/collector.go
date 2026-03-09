package collectors

import (
	"context"
	"errors"
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
	var collectErr error
	stats := models.SystemStats{
		Timestamp: time.Now().UTC(),
	}

	if err := ctx.Err(); err != nil {
		return stats, errors.Join(collectErr, err)
	}

	cpuStats, err := GetCPUStats()
	if err != nil {
		collectErr = errors.Join(collectErr, err)
	}
	stats.CPU = cpuStats

	if err := ctx.Err(); err != nil {
		return stats, errors.Join(collectErr, err)
	}

	memoryStats, err := GetMemoryStats()
	if err != nil {
		collectErr = errors.Join(collectErr, err)
	}
	stats.Memory = memoryStats

	if err := ctx.Err(); err != nil {
		return stats, errors.Join(collectErr, err)
	}

	diskStats, err := GetDiskStats()
	if err != nil {
		collectErr = errors.Join(collectErr, err)
	}
	stats.Disk = diskStats

	if err := ctx.Err(); err != nil {
		return stats, errors.Join(collectErr, err)
	}

	networkStats, err := GetNetworkStats()
	if err != nil {
		collectErr = errors.Join(collectErr, err)
	}
	stats.Network = networkStats

	if err := ctx.Err(); err != nil {
		return stats, errors.Join(collectErr, err)
	}

	processStats, err := GetProcessStats()
	if err != nil {
		collectErr = errors.Join(collectErr, err)
	}
	stats.Processes = processStats

	if err := ctx.Err(); err != nil {
		return stats, errors.Join(collectErr, err)
	}

	appStats, err := GetAppStats()
	if err != nil {
		collectErr = errors.Join(collectErr, err)
	}
	stats.Apps = appStats

	return stats, collectErr
}
