import Foundation

struct NetworkStats: Codable, Identifiable {
    var id: String { networkInterface }
    var networkInterface: String = ""
    var bytesSent: UInt64 = 0
    var bytesRecv: UInt64 = 0
    var packetsSent: UInt64 = 0
    var packetsRecv: UInt64 = 0

    enum CodingKeys: String, CodingKey {
        case networkInterface = "interface"
        case bytesSent, bytesRecv, packetsSent, packetsRecv
    }
}
