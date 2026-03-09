import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryPercent: Double = 0
    @Published var diskPercent: Double = 0
    @Published var networkSent: UInt64 = 0
    @Published var networkRecv: UInt64 = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        MonitorService.shared.$stats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.updateFromStats(stats)
            }
            .store(in: &cancellables)
    }

    private func updateFromStats(_ stats: SystemStats) {
        cpuUsage = stats.cpu.usagePercent
        memoryPercent = stats.memory.usedPercent
        diskPercent = stats.disk.first?.usedPercent ?? 0
        networkSent = stats.network.reduce(0) { $0 + $1.bytesSent }
        networkRecv = stats.network.reduce(0) { $0 + $1.bytesRecv }
    }
}
