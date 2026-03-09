import Foundation

struct NetworkStats: Codable, Identifiable {
    var id: String { networkInterface }
    let networkInterface: String
    let bytesSent: UInt64
    let bytesRecv: UInt64
    let packetsSent: UInt64
    let packetsRecv: UInt64

    enum CodingKeys: String, CodingKey {
        case networkInterface = "interface"
        case bytesSent, bytesRecv, packetsSent, packetsRecv
    }
}
