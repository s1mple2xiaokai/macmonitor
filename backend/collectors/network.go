package collectors

import (
	"fmt"

	"macmonitor/models"

	gopsnet "github.com/shirou/gopsutil/v3/net"
)

func GetNetworkStats() ([]models.NetworkStats, error) {
	ioCounters, err := gopsnet.IOCounters(true)
	if err != nil {
		return nil, fmt.Errorf("collect network stats: %w", err)
	}

	stats := make([]models.NetworkStats, 0, len(ioCounters))
	for _, counter := range ioCounters {
		stats = append(stats, models.NetworkStats{
			Interface:   counter.Name,
			BytesSent:   counter.BytesSent,
			BytesRecv:   counter.BytesRecv,
			PacketsSent: counter.PacketsSent,
			PacketsRecv: counter.PacketsRecv,
		})
	}

	return stats, nil
}
