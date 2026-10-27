import SwiftUI

struct TerminalView: View {
    @StateObject private var viewModel = TerminalViewModel()
    @ObservedObject private var terminalConfig = TerminalConfig.shared
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Circle().fill(Color.red).frame(width: 12, height: 12)
                    Circle().fill(Color.yellow).frame(width: 12, height: 12)
                    Circle().fill(Color.green).frame(width: 12, height: 12)
                }

                Spacer()

                Text("Terminal - \(terminalConfig.host)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.gray.opacity(0.8))

                Spacer()

                HStack(spacing: 6) {
                    Button(action: {
                        viewModel.connect()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }

                    Circle()
                        .fill(viewModel.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(viewModel.isConnected ? "Connected" : "Offline")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(viewModel.isConnected ? .green : .red)
                }

                if let error = viewModel.connectionError {
                    Text(error)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
            
            // Output Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.lines) { line in
                            HStack(alignment: .top, spacing: 0) {
                                ForEach(line.segments) { segment in
                                    Text(segment.text)
                                        .foregroundColor(segment.color)
                                        .font(.system(size: 14, design: .monospaced))
                                }
                            }
                        }
                        
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(12)
                }
                .background(Color(red: 0.05, green: 0.05, blue: 0.08))
                .onChange(of: viewModel.lines.count) { _ in
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .onTapGesture {
                    isInputFocused = true
                }
            }
            
            // Toolbar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    TerminalToolbarButton(title: "Ctrl+C", icon: "control") { viewModel.sendSpecialCommand("Ctrl+C") }
                    TerminalToolbarButton(title: "Tab", icon: "arrow.right.to.line") { viewModel.sendSpecialCommand("Tab") }
                    TerminalToolbarButton(title: "Clear", icon: "trash") { viewModel.sendSpecialCommand("Clear") }
                    TerminalToolbarButton(title: "↑", icon: "arrow.up") { viewModel.sendSpecialCommand("Up") }
                    TerminalToolbarButton(title: "↓", icon: "arrow.down") { viewModel.sendSpecialCommand("Down") }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(Color(red: 0.12, green: 0.12, blue: 0.14))
            
            // Input Area
            HStack(spacing: 8) {
                Text("➜")
                    .foregroundColor(.green)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                
                Text("~")
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                
                TextField("", text: $viewModel.inputCommand, onCommit: {
                    viewModel.sendCommand()
                })
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white)
                .focused($isInputFocused)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.08, green: 0.08, blue: 0.1))
        }
        .onAppear {
            viewModel.connect()
        }
        .onDisappear {
            viewModel.disconnect()
        }
        .navigationBarHidden(true)
    }
}

struct TerminalToolbarButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
            }
            .foregroundColor(Color.white.opacity(0.85))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(red: 0.2, green: 0.2, blue: 0.25))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct TerminalView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalView()
    }
}
