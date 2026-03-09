package collectors

import (
	"fmt"

	"macmonitor/models"

	"github.com/shirou/gopsutil/v3/mem"
)

func GetMemoryStats() (models.MemoryStats, error) {
	vm, err := mem.VirtualMemory()
	if err != nil {
		return models.MemoryStats{}, fmt.Errorf("collect memory stats: %w", err)
	}

	return models.MemoryStats{
		Total:       vm.Total,
		Used:        vm.Used,
		UsedPercent: vm.UsedPercent,
		Free:        vm.Available,
	}, nil
}
