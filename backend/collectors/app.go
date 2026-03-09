package collectors

import (
	"bufio"
	"errors"
	"fmt"
	"os/exec"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	"macmonitor/models"
)

func GetAppStats() ([]models.AppInfo, error) {
	// 使用更精确的 ps 命令格式，确保解析正确
	cmd := exec.Command("ps", "-axo", "pid=,pcpu=,rss=,comm=")
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("run ps for app stats: %w", err)
	}

	var collectErr error
	apps := make([]models.AppInfo, 0)
	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}

		// ps 输出格式: PID CPU% RSS COMMAND
		// 使用正则表达式或手动解析更可靠
		// 格式: pid pcpu rss comm
		parts := strings.SplitN(line, " ", 4)
		if len(parts) < 4 {
			// 尝试更宽松的分割
			fields := strings.Fields(line)
			if len(fields) < 4 {
				collectErr = errors.Join(collectErr, fmt.Errorf("invalid ps line: %q", line))
				continue
			}
			parts = fields
		}

		pid64, err := strconv.ParseInt(parts[0], 10, 32)
		if err != nil {
			collectErr = errors.Join(collectErr, fmt.Errorf("parse pid %q: %w", parts[0], err))
			continue
		}

		cpuPercent, err := strconv.ParseFloat(parts[1], 64)
		if err != nil {
			collectErr = errors.Join(collectErr, fmt.Errorf("parse cpu %q for pid %d: %w", parts[1], pid64, err))
			continue
		}

		rssKB, err := strconv.ParseFloat(parts[2], 64)
		if err != nil {
			collectErr = errors.Join(collectErr, fmt.Errorf("parse rss %q for pid %d: %w", parts[2], pid64, err))
			continue
		}

		// command 可能包含空格，重新组合剩余部分
		command := parts[3]
		if len(parts) > 4 {
			command = strings.Join(parts[3:], " ")
		}
		if !isUserApp(command) {
			continue
		}

		apps = append(apps, models.AppInfo{
			Name:       appNameFromCommand(command),
			PID:        int32(pid64),
			CPUPercent: cpuPercent,
			MemoryMB:   rssKB / 1024.0,
		})
	}
	if err := scanner.Err(); err != nil {
		collectErr = errors.Join(collectErr, fmt.Errorf("scan ps output: %w", err))
	}

	sort.Slice(apps, func(i, j int) bool {
		return apps[i].CPUPercent > apps[j].CPUPercent
	})

	return apps, collectErr
}

func isUserApp(command string) bool {
	if command == "" {
		return false
	}

	systemPrefixes := []string{
		"/System/",
		"/usr/",
		"/bin/",
		"/sbin/",
		"/Library/",
	}
	for _, prefix := range systemPrefixes {
		if strings.HasPrefix(command, prefix) {
			return false
		}
	}

	if strings.Contains(command, ".app/") {
		return true
	}
	return strings.HasPrefix(command, "/Applications/") || strings.HasPrefix(command, "/Users/")
}

func appNameFromCommand(command string) string {
	if idx := strings.Index(command, ".app/"); idx > 0 {
		prefix := command[:idx+4]
		base := filepath.Base(prefix)
		return strings.TrimSuffix(base, ".app")
	}

	base := filepath.Base(command)
	if base == "" {
		return "unknown"
	}
	return base
}
