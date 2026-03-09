package collectors

import (
	"errors"
	"fmt"
	"sort"

	"macmonitor/models"

	"github.com/shirou/gopsutil/v3/process"
)

const topProcessLimit = 15

func GetProcessStats() ([]models.ProcessInfo, error) {
	pids, err := process.Pids()
	if err != nil {
		return nil, fmt.Errorf("list processes: %w", err)
	}

	stats := make([]models.ProcessInfo, 0, len(pids))
	var collectErr error

	for _, pid := range pids {
		p, pErr := process.NewProcess(pid)
		if pErr != nil {
			collectErr = errors.Join(collectErr, fmt.Errorf("load process %d: %w", pid, pErr))
			continue
		}

		name, nameErr := p.Name()
		if nameErr != nil {
			collectErr = errors.Join(collectErr, fmt.Errorf("read name for pid %d: %w", pid, nameErr))
			name = "unknown"
		}

		cpuPercent, cpuErr := p.CPUPercent()
		if cpuErr != nil {
			collectErr = errors.Join(collectErr, fmt.Errorf("read cpu for pid %d: %w", pid, cpuErr))
		}

		var memoryBytes uint64
		memInfo, memErr := p.MemoryInfo()
		if memErr != nil {
			collectErr = errors.Join(collectErr, fmt.Errorf("read memory for pid %d: %w", pid, memErr))
		} else if memInfo != nil {
			memoryBytes = memInfo.RSS
		}

		status := "unknown"
		statuses, statusErr := p.Status()
		if statusErr != nil {
			collectErr = errors.Join(collectErr, fmt.Errorf("read status for pid %d: %w", pid, statusErr))
		} else if len(statuses) > 0 {
			status = statuses[0]
		}

		stats = append(stats, models.ProcessInfo{
			PID:         pid,
			Name:        name,
			CPUPercent:  cpuPercent,
			MemoryBytes: memoryBytes,
			Status:      status,
		})
	}

	sort.Slice(stats, func(i, j int) bool {
		return stats[i].CPUPercent > stats[j].CPUPercent
	})
	if len(stats) > topProcessLimit {
		stats = stats[:topProcessLimit]
	}

	return stats, collectErr
}
