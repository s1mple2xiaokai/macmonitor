import Foundation

struct DiskStats: Codable, Identifiable {
    var id: String { path }
    var path: String = ""
    var total: UInt64 = 0
    var used: UInt64 = 0
    var usedPercent: Double = 0
    var free: UInt64 = 0
}
