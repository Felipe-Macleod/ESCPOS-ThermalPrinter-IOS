import Foundation

extension String {
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

enum TokenKind {
    case TEXT
    case TAG
    case ATTRIBUTE

    case OPEN_TAG
    case CLOSE_TAG
    case BACKSLASH
    case ALIGNMENT
    case LINE_BREAK
    case ASSIGNMENT
}

struct Token {
    let type: TokenKind
    let value: String

    func debug() {
        print("\(type) (\(value))")
    }
}

struct Lexer {
    let lines: [String]
    var tokens: [Token] = []
    var atLine: Int = 0
    var atCol: Int = 0

    init (source: String = "") {
        self.lines = source.split(separator: "\n").map { String($0) }
    }

    mutating func push(_ type: TokenKind, _ value: String) {
        self.tokens.append(Token(type: type, value: value))
    }

    func plainText() -> String {
        var text = ""
        for token in self.tokens {
            if(token.type == .TEXT) {
                text.append(token.value)
                text.append(" ")
                continue
            }
            if(token.type == .LINE_BREAK) {
                text.append("\n")
                continue
            }
        }
        return text
    }

    func getActLine() -> String {
        if(atLine < lines.count) {
            return lines[atLine]
        }
        return ""
    }

    func getActChar(_ offset: Int = 0) -> String {
        let line = getActLine()
        if(atCol + offset < line.count) {
            return line[atCol + offset]
        }
        return ""
    }

    mutating func parseAlignment() {
        if(getActChar() == "[" && getActChar(2) == "]") {
            self.push(.ALIGNMENT, getActChar(1))
            atCol += 3
        }
    }

    mutating func tokenize() {
        for (index, line) in lines.enumerated() {
            atCol = 0
            while( atCol < line.count ) {
                if(line[atCol] == "[") {
                    parseAlignment()
                    continue
                }
                if(line[atCol] == "<") {
                    self.push(.OPEN_TAG, "")
                    atCol += 1
                    if(line[atCol] == "/") {
                        self.push(.BACKSLASH, "")
                        atCol += 1
                    }
                    while(line[atCol] != ">" && atCol < line.count) {
                        if(line[atCol] == " ") {
                            atCol += 1
                            continue
                        }
                        if(line[atCol] == "=") {
                            self.push(.ASSIGNMENT, "")
                            atCol += 1
                            continue
                        }
                        var attr = ""
                        while(line[atCol] != "=" && line[atCol] != ">" && line[atCol] != " " && atCol < line.count) {
                            attr.append(line[atCol])
                            atCol += 1
                        }
                        self.push(.ATTRIBUTE, attr)
                    }
                    self.push(.CLOSE_TAG, "")
                    atCol += 1
                    continue
                }
                var text = ""
                while((line[atCol] != "[" && line[atCol + 2] != "]") && line[atCol] != "<" && atCol < line.count) {
                    text.append(line[atCol])
                    atCol += 1
                }
                self.push(.TEXT, text)
            }

            if(index != lines.count - 1) {
                atLine += 1
                self.push(.LINE_BREAK, "")
            }
        }
    }
}

