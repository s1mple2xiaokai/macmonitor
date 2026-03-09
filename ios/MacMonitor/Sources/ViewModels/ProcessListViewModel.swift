import SwiftUI
import Combine

@MainActor
class ProcessListViewModel: ObservableObject {
    @Published var processes: [ProcessInfo] = []
    @Published var sortOrder: SortOrder = .cpu

    enum SortOrder {
        case cpu, memory
    }

    var sortedProcesses: [ProcessInfo] {
        switch sortOrder {
        case .cpu:
            return processes.sorted { $0.cpuPercent > $1.cpuPercent }
        case .memory:
            return processes.sorted { $0.memoryBytes > $1.memoryBytes }
        }
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        MonitorService.shared.$stats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.processes = Array(stats.processes.prefix(50))
            }
            .store(in: &cancellables)
    }
}
