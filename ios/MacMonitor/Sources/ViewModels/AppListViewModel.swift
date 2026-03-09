import SwiftUI
import Combine

@MainActor
class AppListViewModel: ObservableObject {
    @Published var apps: [AppInfo] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        MonitorService.shared.$stats
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.apps = stats.apps
            }
            .store(in: &cancellables)
    }
}
