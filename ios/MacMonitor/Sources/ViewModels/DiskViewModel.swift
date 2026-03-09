import SwiftUI
import Combine

@MainActor
class DiskViewModel: ObservableObject {
    @Published var disks: [DiskStats] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        MonitorService.shared.$stats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.disks = stats.disk
            }
            .store(in: &cancellables)
    }
}
