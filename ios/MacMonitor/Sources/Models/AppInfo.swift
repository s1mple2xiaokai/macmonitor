import Foundation

struct AppInfo: Codable, Identifiable {
    var id: Int32 { pid }
    let name: String
    let pid: Int32
    let cpuPercent: Double
    let memoryMB: Double
}
