import Foundation

struct CPUStats: Codable {
    var usagePercent: Double = 0
    var cores: Int = 0
    var modelName: String?
}
