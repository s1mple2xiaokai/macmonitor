import Foundation
import SwiftUI

class TerminalConfig: ObservableObject {
    static let shared = TerminalConfig()

    @AppStorage("terminalToken") var token: String = "macmonitor123"
    @AppStorage("terminalHost") var host: String = "172.18.239.133:8080"
    @AppStorage("terminalPath") var path: String = "/terminal/ws"
    @AppStorage("useLocalNetwork") var useLocalNetwork: Bool = true

    private init() {}

    var websocketURL: URL? {
        var components = URLComponents()
        components.scheme = "ws"
        components.host = host.components(separatedBy: ":").first ?? host
        if let portString = host.components(separatedBy: ":").last, let port = Int(portString) {
            components.port = port
        } else {
            components.port = 8080
        }
        components.path = path
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        return components.url
    }
}
