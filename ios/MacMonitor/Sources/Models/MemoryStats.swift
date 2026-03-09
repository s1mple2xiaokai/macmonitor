import Foundation

struct MemoryStats: Codable {
    let total: UInt64
    let used: UInt64
    let usedPercent: Double
    let free: UInt64
}
