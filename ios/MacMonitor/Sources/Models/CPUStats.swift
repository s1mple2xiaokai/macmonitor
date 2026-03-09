import Foundation

struct CPUStats: Codable {
    let usagePercent: Double
    let cores: Int
    let modelName: String?
}
