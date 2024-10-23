struct Parser {
    let tokens: [Token]
    var at: Int = 0
    var lines: [LineStmt] = [LineStmt(columns: [ColumnStmt(alignment: "L")])]

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func getActToken() -> Token {
        if(at < tokens.count) {
            return tokens[at]
        }
        return Token(type: .NONE, value: "")
    }

    mutating func parse() -> [LineStmt] {
        lines = [LineStmt(columns: [ColumnStmt(alignment: "L")])]

        while(getActToken().type != .NONE) {
            switch (getActToken().type) {
                case .LINE_BREAK:
                    lines.append(LineStmt(columns: [ColumnStmt(alignment: "L")]))
                default:
                    at += 1
            }
        }

        return lines
    }
}

func parseTokens(tokens: [Token]) -> [LineStmt] {
    var lines = [LineStmt(columns: [])]
    var at = 0
    var tagStack: [TagStmt] = []

    while at < tokens.count {
        let initAt = at
        switch (tokens[at].type) {
            case .LINE_BREAK:
                lines.append(LineStmt(columns: []))
            case .ALIGNMENT:
                lines[lines.count - 1].columns.append(ColumnStmt(alignment: tokens[at].value))
            case .TAG:
                tagStack.append(TagStmt(tag: tokens[at].value))
            case .BACKSLASH:
                let tag = tagStack.removeLast()
                if tagStack.count > 0 {
                    tagStack[tagStack.count - 1].children.append(tag)
                }
                else {
                    lines[lines.count - 1].columns[lines[lines.count - 1].columns.count - 1].children.append(tag)
                }
                at += 2
            case .ATTRIBUTE:
                let key = tokens[at].value
                var value = "true"
                if(tokens[at + 1].type == .ASSIGNMENT) {
                    value = tokens[at + 2].value
                    at += 2
                }
                tagStack[tagStack.count - 1].attributes[key] = value
                at += 1
            case .TEXT:
                let textTag = TagStmt(tag: "text", attributes: ["value": tokens[at].value])
                if tagStack.count > 0 {
                    tagStack[tagStack.count - 1].children.append(textTag)
                }
                else {
                    lines[lines.count - 1].columns[lines[lines.count - 1].columns.count - 1].children.append(textTag)
                }
            default:
                break
        }
        if at == initAt {
            at += 1
        }
    }

    return lines
}
