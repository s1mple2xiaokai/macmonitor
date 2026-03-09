import SwiftUI
import Combine

@MainActor
class NetworkViewModel: ObservableObject {
    @Published var interfaces: [NetworkStats] = []
    @Published var totalSent: UInt64 = 0
    @Published var totalRecv: UInt64 = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        MonitorService.shared.$stats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.interfaces = stats.network
                self?.totalSent = stats.network.reduce(0) { $0 + $1.bytesSent }
                self?.totalRecv = stats.network.reduce(0) { $0 + $1.bytesRecv }
            }
            .store(in: &cancellables)
    }
}
