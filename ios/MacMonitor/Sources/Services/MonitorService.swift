import Foundation
import Combine

@MainActor
class MonitorService: ObservableObject {
    static let shared = MonitorService()

    @Published var stats: SystemStats?
    @Published var isConnected: Bool = false
    @Published var errorMessage: String?
    @Published var serverAddress: String = "http://localhost:8080"

    private var timer: AnyCancellable?
    private var refreshInterval: TimeInterval = 2.0

    private init() {
        loadServerAddress()
    }

    func startMonitoring() {
        stopMonitoring()

        timer = Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.fetchStats()
                }
            }

        Task {
            await fetchStats()
        }
    }

    func stopMonitoring() {
        timer?.cancel()
        timer = nil
    }

    func fetchStats() async {
        guard let url = URL(string: "\(serverAddress)/api/stats") else {
            errorMessage = "Invalid server address"
            isConnected = false
            return
        }

        do {
            let newStats = try await APIClient.shared.fetch(SystemStats.self, from: url)
            self.stats = newStats
            self.isConnected = true
            self.errorMessage = nil
        } catch {
            self.errorMessage = error.localizedDescription
            self.isConnected = false
        }
    }

    func updateServerAddress(_ address: String) {
        serverAddress = address
        saveServerAddress()
    }

    func updateRefreshInterval(_ interval: TimeInterval) {
        refreshInterval = interval
        if timer != nil {
            startMonitoring()
        }
    }

    private func saveServerAddress() {
        UserDefaults.standard.set(serverAddress, forKey: "serverAddress")
    }

    private func loadServerAddress() {
        if let saved = UserDefaults.standard.string(forKey: "serverAddress") {
            serverAddress = saved
        }
    }
}
