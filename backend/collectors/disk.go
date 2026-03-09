package collectors

import (
	"errors"
	"fmt"

	"macmonitor/models"

	"github.com/shirou/gopsutil/v3/disk"
)

func GetDiskStats() ([]models.DiskStats, error) {
	partitions, err := disk.Partitions(false)
	if err != nil {
		return nil, fmt.Errorf("list disk partitions: %w", err)
	}

	stats := make([]models.DiskStats, 0, len(partitions))
	var collectErr error

	for _, partition := range partitions {
		usage, usageErr := disk.Usage(partition.Mountpoint)
		if usageErr != nil {
			collectErr = errors.Join(
				collectErr,
				fmt.Errorf("collect disk usage for %s: %w", partition.Mountpoint, usageErr),
			)
			continue
		}

		stats = append(stats, models.DiskStats{
			Path:        partition.Mountpoint,
			Total:       usage.Total,
			Used:        usage.Used,
			UsedPercent: usage.UsedPercent,
			Free:        usage.Free,
		})
	}

	return stats, collectErr
}
