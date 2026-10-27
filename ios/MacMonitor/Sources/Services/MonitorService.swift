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
        // Fetch individual stats from separate endpoints
        async let cpuResult: CPUStats? = fetchCPU()
        async let memoryResult: MemoryStats? = fetchMemory()
        async let diskResult: [DiskStats]? = fetchDisk()
        async let networkResult: [NetworkStats]? = fetchNetwork()

        let cpu = await cpuResult
        let memory = await memoryResult
        let disk = await diskResult
        let network = await networkResult

        var newStats = SystemStats()
        newStats.cpu = cpu ?? CPUStats()
        newStats.memory = memory ?? MemoryStats()
        newStats.disk = disk ?? [DiskStats]()
        newStats.network = network ?? [NetworkStats]()

        // Check if we got any valid data
        if cpu != nil || memory != nil {
            self.stats = newStats
            self.isConnected = true
            self.errorMessage = nil
        } else {
            self.isConnected = false
            self.errorMessage = "Failed to fetch stats"
        }
    }

    private func fetchCPU() async -> CPUStats? {
        guard let url = URL(string: "\(serverAddress)/api/cpu") else { return nil }
        return try? await APIClient.shared.fetch(CPUStats.self, from: url)
    }

    private func fetchMemory() async -> MemoryStats? {
        guard let url = URL(string: "\(serverAddress)/api/memory") else { return nil }
        return try? await APIClient.shared.fetch(MemoryStats.self, from: url)
    }

    private func fetchDisk() async -> [DiskStats]? {
        guard let url = URL(string: "\(serverAddress)/api/disk") else { return nil }
        return try? await APIClient.shared.fetch([DiskStats].self, from: url)
    }

    private func fetchNetwork() async -> [NetworkStats]? {
        guard let url = URL(string: "\(serverAddress)/api/network") else { return nil }
        return try? await APIClient.shared.fetch([NetworkStats].self, from: url)
    }

    struct CleanupResponse: Codable {
        let success: Bool
        let message: String
    }

    func cleanupMemory() async {
        guard let url = URL(string: "\(serverAddress)/api/memory/cleanup") else {
            errorMessage = "Invalid server address"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // 清理成功后刷新内存数据
                    await fetchStats()
                } else {
                    // 解析错误消息
                    if let cleanupResponse = try? JSONDecoder().decode(CleanupResponse.self, from: data) {
                        errorMessage = cleanupResponse.message
                    } else {
                        errorMessage = "清理失败: \(httpResponse.statusCode)"
                    }
                }
            }
        } catch {
            errorMessage = "清理内存失败: \(error.localizedDescription)"
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
