import Foundation

class TerminalService: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession
    private var reconnectTimer: Timer?
    private var currentURL: URL?

    @Published var isConnected: Bool = false
    @Published var connectionError: String? = nil

    var onMessageReceived: ((String) -> Void)?

    init() {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        self.urlSession = URLSession(configuration: config)
    }

    func connect(url: URL) {
        currentURL = url
        reconnectTimer?.invalidate()
        disconnect()

        var request = URLRequest(url: url)
        request.timeoutInterval = 30

        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()

        isConnected = true
        connectionError = nil

        receiveMessage()
        sendPing()
    }

    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }

    func sendCommand(_ command: String) {
        guard isConnected else {
            // Try to reconnect and send
            if let url = currentURL {
                connect(url: url)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sendCommand(command)
                }
            }
            return
        }
        let message = URLSessionWebSocketTask.Message.string(command)
        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.connectionError = "Send failed: \(error.localizedDescription)"
                    self?.scheduleReconnect()
                }
            }
        }
    }

    private func scheduleReconnect() {
        disconnect()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            if let url = self?.currentURL {
                self?.connect(url: url)
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.connectionError = "Connection error: \(error.localizedDescription)"
                    self.scheduleReconnect()
                }
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self.onMessageReceived?(text)
                    }
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self.onMessageReceived?(text)
                        }
                    }
                @unknown default:
                    break
                }

                // Continue receiving
                if self.isConnected {
                    self.receiveMessage()
                }
            }
        }
    }

    private func sendPing() {
        guard isConnected else { return }
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.connectionError = "Ping failed: \(error.localizedDescription)"
                    self?.scheduleReconnect()
                }
            } else {
                DispatchQueue.global().asyncAfter(deadline: .now() + 15) {
                    self?.sendPing()
                }
            }
        }
    }
}
