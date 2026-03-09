import SwiftUI
import Combine

@MainActor
class CPUViewModel: ObservableObject {
    @Published var usage: Double = 0
    @Published var cores: Int = 0
    @Published var modelName: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        MonitorService.shared.$stats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.usage = stats.cpu.usagePercent
                self?.cores = stats.cpu.cores
                self?.modelName = stats.cpu.modelName ?? "Unknown"
            }
            .store(in: &cancellables)
    }
}
