import SwiftUI
import Combine

@MainActor
class MemoryViewModel: ObservableObject {
    @Published var used: UInt64 = 0
    @Published var total: UInt64 = 0
    @Published var free: UInt64 = 0
    @Published var percent: Double = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        MonitorService.shared.$stats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.used = stats.memory.used
                self?.total = stats.memory.total
                self?.free = stats.memory.free
                self?.percent = stats.memory.usedPercent
            }
            .store(in: &cancellables)
    }
}
