import Foundation

struct MemoryCleanupResponse: Decodable {
    let success: Bool
    let message: String
    let command: String
    let output: String?
    let timestamp: String
}
