import Foundation

struct MemoryStats: Codable {
    var total: UInt64 = 0
    var used: UInt64 = 0
    var usedPercent: Double = 0
    var free: UInt64 = 0
}
