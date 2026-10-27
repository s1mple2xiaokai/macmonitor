import Foundation
import SwiftUI

struct ANSISegment: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
}

class ANSIParser {
    private let colorMap: [String: Color] = [
        "30": .black, "31": .red, "32": .green, "33": .yellow,
        "34": .blue, "35": .purple, "36": .cyan, "37": .white,
        "90": .gray, "91": .red, "92": .green, "93": .yellow,
        "94": .blue, "95": .purple, "96": .cyan, "97": .white
    ]

    func parse(_ text: String) -> [[ANSISegment]] {
        var lines: [[ANSISegment]] = []
        let rawLines = text.components(separatedBy: .newlines)
        
        for rawLine in rawLines {
            var segments: [ANSISegment] = []
            var currentColor: Color = .white
            
            let parts = rawLine.components(separatedBy: "\u{1B}[")
            
            for (index, part) in parts.enumerated() {
                if index == 0 {
                    if !part.isEmpty {
                        segments.append(ANSISegment(text: part, color: .white))
                    }
                    continue
                }
                
                guard let mIndex = part.firstIndex(of: "m") else {
                    segments.append(ANSISegment(text: "\u{1B}[" + part, color: currentColor))
                    continue
                }
                
                let codeString = String(part[..<mIndex])
                let textAfter = String(part[part.index(after: mIndex)...])
                
                let codes = codeString.components(separatedBy: ";")
                for code in codes {
                    if code == "0" || code.isEmpty {
                        currentColor = .white
                    } else if let newColor = colorMap[code] {
                        currentColor = newColor
                    }
                }
                
                if !textAfter.isEmpty {
                    segments.append(ANSISegment(text: textAfter, color: currentColor))
                }
            }
            lines.append(segments)
        }
        
        return lines
    }
}
