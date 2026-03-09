import Foundation

struct ProcessInfo: Codable, Identifiable {
    var id: Int32 { pid }
    let pid: Int32
    let name: String
    let cpuPercent: Double
    let memoryBytes: UInt64
    let status: String?
}
