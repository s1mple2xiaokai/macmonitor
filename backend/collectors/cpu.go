package collectors

import (
	"fmt"

	"macmonitor/models"

	"github.com/shirou/gopsutil/v3/cpu"
)

func GetCPUStats() (models.CPUStats, error) {
	stats := models.CPUStats{
		ModelName: "unknown",
	}

	usage, err := cpu.Percent(0, false)
	if err != nil {
		return stats, fmt.Errorf("collect cpu usage: %w", err)
	}
	if len(usage) > 0 {
		stats.UsagePercent = usage[0]
	}

	cores, err := cpu.Counts(true)
	if err != nil {
		return stats, fmt.Errorf("collect cpu cores: %w", err)
	}
	if cores > 0 {
		stats.Cores = cores
	}

	info, err := cpu.Info()
	if err != nil {
		return stats, fmt.Errorf("collect cpu model: %w", err)
	}
	if len(info) > 0 && info[0].ModelName != "" {
		stats.ModelName = info[0].ModelName
	}

	return stats, nil
}
