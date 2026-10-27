import Foundation
import SwiftUI

struct TerminalOutputSegment: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
}

struct TerminalLine: Identifiable {
    let id = UUID()
    let segments: [TerminalOutputSegment]
}

class TerminalViewModel: ObservableObject {
    @Published var lines: [TerminalLine] = []
    @Published var inputCommand: String = ""
    @Published var isConnected: Bool = false
    @Published var commandHistory: [String] = []
    @Published var connectionError: String? = nil
    private var historyIndex: Int = -1

    private let service = TerminalService()
    let config = TerminalConfig.shared
    private let ansiParser = ANSIParser()

    init() {
        service.onMessageReceived = { [weak self] text in
            self?.appendOutput(text)
        }

        // Observe connection state
        service.$isConnected.assign(to: &$isConnected)
        service.$connectionError.assign(to: &$connectionError)

        // Add welcome message
        appendOutput("\u{001B}[32mWelcome to MacMonitor Terminal!\u{001B}[0m\n")
        appendOutput("\u{001B}[90mConnecting to \(config.host)...\u{001B}[0m\n")
    }
    
    func connect() {
        guard let url = config.websocketURL else {
            appendOutput("\u{001B}[31mError: Invalid WebSocket URL\u{001B}[0m\n")
            return
        }
        service.connect(url: url)
    }
    
    func disconnect() {
        service.disconnect()
        appendOutput("\u{001B}[33mDisconnected from server.\u{001B}[0m\n")
    }
    
    func sendCommand() {
        let command = inputCommand.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        
        appendOutput("\u{001B}[34m➜\u{001B}[0m \(command)\n")
        service.sendCommand(command + "\n")
        
        commandHistory.append(command)
        historyIndex = commandHistory.count
        inputCommand = ""
    }
    
    func sendSpecialCommand(_ action: String) {
        switch action {
        case "Ctrl+C":
            service.sendCommand("\u{0003}") // ETX
            appendOutput("^C\n")
        case "Tab":
            service.sendCommand("\t")
        case "Clear":
            lines.removeAll()
        case "Up":
            if !commandHistory.isEmpty {
                if historyIndex > 0 {
                    historyIndex -= 1
                }
                inputCommand = commandHistory[historyIndex]
            }
        case "Down":
            if !commandHistory.isEmpty {
                if historyIndex < commandHistory.count - 1 {
                    historyIndex += 1
                    inputCommand = commandHistory[historyIndex]
                } else {
                    historyIndex = commandHistory.count
                    inputCommand = ""
                }
            }
        default:
            break
        }
    }
    
    private func appendOutput(_ text: String) {
        let parsedLines = ansiParser.parse(text)
        for parsedLine in parsedLines {
            if parsedLine.isEmpty { continue }
            lines.append(TerminalLine(segments: parsedLine.map { TerminalOutputSegment(text: $0.text, color: $0.color) }))
            
            // Keep buffer size manageable
            if lines.count > 1000 {
                lines.removeFirst(lines.count - 1000)
            }
        }
    }
}
