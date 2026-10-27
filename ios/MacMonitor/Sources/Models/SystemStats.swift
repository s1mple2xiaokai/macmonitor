import Foundation

struct SystemStats: Codable, Identifiable {
    var id: Date { timestamp }
    var cpu: CPUStats = CPUStats()
    var memory: MemoryStats = MemoryStats()
    var disk: [DiskStats] = []
    var network: [NetworkStats] = []
    var processes: [ProcessInfo] = []
    var apps: [AppInfo] = []
    var timestamp: Date = Date()

    enum CodingKeys: String, CodingKey {
        case cpu, memory, disk, network, processes, apps, timestamp
    }
}
