import Foundation

struct SystemStats: Codable, Identifiable {
    var id: Date { timestamp }
    let cpu: CPUStats
    let memory: MemoryStats
    let disk: [DiskStats]
    let network: [NetworkStats]
    let processes: [ProcessInfo]
    let apps: [AppInfo]
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case cpu, memory, disk, network, processes, apps, timestamp
    }
}
