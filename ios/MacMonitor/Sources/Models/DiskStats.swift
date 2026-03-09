import Foundation

struct DiskStats: Codable, Identifiable {
    var id: String { path }
    let path: String
    let total: UInt64
    let used: UInt64
    let usedPercent: Double
    let free: UInt64
}
