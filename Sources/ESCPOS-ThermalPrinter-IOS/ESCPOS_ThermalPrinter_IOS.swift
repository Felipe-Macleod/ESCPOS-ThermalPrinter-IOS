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
    case STRING
    case CONSTANT
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

    mutating func push(_ type: TokenKind, _ value: String, _ walk: Int = 1) {
        self.tokens.append(Token(type: type, value: value))
        atCol += walk
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
            self.push(.ALIGNMENT, getActChar(1), 3)
        }
    }

    mutating func parseString() {
        var text = ""
        if(getActChar() != "\"") {
            return
        }
        atCol += 1
        var actChar = getActChar()
        while(actChar != "\"" && actChar != "") {
            text.append(actChar)
            atCol += 1
            actChar = getActChar()
        }
        self.push(.STRING, text)
    }

    mutating func parseAttribute() {
        var attr = ""
        var actChar = getActChar()
        while(actChar != "=" && actChar != ">" && actChar != " " && actChar != "") {
            attr.append(actChar)
            atCol += 1
            actChar = getActChar()
        }
        switch(self.tokens.last?.type) {
            case .ATTRIBUTE, .CONSTANT, .TAG:
                self.push(.ATTRIBUTE, attr, 0)
            case .ASSIGNMENT:
                self.push(.CONSTANT, attr, 0)
            default:
                self.push(.TAG, attr, 0)
        }
    }

    mutating func parseTag() {
        self.push(.OPEN_TAG, "")
        if(getActChar() == "/") {
            self.push(.BACKSLASH, "")
        }
        var actChar = getActChar()
        while(actChar != ">" && actChar != "") {
            switch(actChar) {
                case " ":
                    atCol += 1
                case "=":
                    self.push(.ASSIGNMENT, "")
                case "\"":
                    self.parseString()
                default:
                    self.parseAttribute()
            }
            actChar = getActChar()
        }
        self.push(.CLOSE_TAG, "")
    }

    mutating func parseText() {
        var text = ""
        var actChar = getActChar()
        while(actChar != "[" && actChar != "<" && actChar != "") {
            text.append(actChar)
            atCol += 1
            actChar = getActChar()
        }
        if(text != "") {
            self.push(.TEXT, text, 0)
        }
    }

    mutating func tokenize() {
        for (index, _) in lines.enumerated() {
            atCol = 0
            while(getActChar() != "") {
                switch(getActChar()) {
                case "[":
                    parseAlignment()
                case "<":
                    parseTag()
                default:
                    parseText()
                }
            }
            if(index != lines.count - 1) {
                atLine += 1
                self.push(.LINE_BREAK, "", 0)
            }
        }
    }
}

