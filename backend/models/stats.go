package models

import "time"

type CPUStats struct {
	UsagePercent float64 `json:"usagePercent"`
	Cores        int     `json:"cores"`
	ModelName    string  `json:"modelName"`
}

type MemoryStats struct {
	Total       uint64  `json:"total"`
	Used        uint64  `json:"used"`
	UsedPercent float64 `json:"usedPercent"`
	Free        uint64  `json:"free"`
}

type DiskStats struct {
	Path        string  `json:"path"`
	Total       uint64  `json:"total"`
	Used        uint64  `json:"used"`
	UsedPercent float64 `json:"usedPercent"`
	Free        uint64  `json:"free"`
}

type NetworkStats struct {
	Interface   string `json:"interface"`
	BytesSent   uint64 `json:"bytesSent"`
	BytesRecv   uint64 `json:"bytesRecv"`
	PacketsSent uint64 `json:"packetsSent"`
	PacketsRecv uint64 `json:"packetsRecv"`
}

type ProcessInfo struct {
	PID         int32   `json:"pid"`
	Name        string  `json:"name"`
	CPUPercent  float64 `json:"cpuPercent"`
	MemoryBytes uint64  `json:"memoryBytes"`
	Status      string  `json:"status"`
}

type AppInfo struct {
	Name      string  `json:"name"`
	PID       int32   `json:"pid"`
	CPUPercent float64 `json:"cpuPercent"`
	MemoryMB  float64 `json:"memoryMB"`
}

type SystemStats struct {
	Timestamp time.Time      `json:"timestamp"`
	CPU        CPUStats       `json:"cpu"`
	Memory     MemoryStats    `json:"memory"`
	Disk       []DiskStats    `json:"disk"`
	Network    []NetworkStats `json:"network"`
	Processes  []ProcessInfo  `json:"processes"`
	Apps       []AppInfo      `json:"apps"`
}
