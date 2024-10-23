struct TextStmt {
    let text: String
}

struct TagStmt {
    let tag: String
    var attributes: [String: String]
    var children: [TagStmt] = []

    init(tag: String, attributes: [String: String] = [:]) {
        self.tag = tag
        self.attributes = attributes
    }

    func debug(_ level: Int = 0) {
        if tag == "text" {
            print("\(attributes["value"]!)", terminator: "")
            return
        }

        print("<\(tag) \(attributes.map { "\($0)=\"\($1)\"" }.joined(separator: " "))>", terminator: "")
        for child in children {
            child.debug(level + 1)
        }
        print("</\(tag)>", terminator: "")
    }
}

struct ColumnStmt {
    let alignment: String
    var children: [TagStmt] = []
}
extension ColumnStmt: Equatable {
    static func == (lhs: ColumnStmt, rhs: ColumnStmt) -> Bool {
        return lhs.alignment == rhs.alignment
    }
}

struct LineStmt {
    var columns: [ColumnStmt]
}
extension LineStmt: Equatable {
    static func == (lhs: LineStmt, rhs: LineStmt) -> Bool {
        return lhs.columns == rhs.columns
    }
}
