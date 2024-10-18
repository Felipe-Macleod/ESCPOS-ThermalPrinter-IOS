import XCTest
@testable import ESCPOS_ThermalPrinter_IOS

final class ESCPOS_ThermalPrinter_IOSTests: XCTestCase {
    func testLexer() throws {
        let source = "[C]Center\n[L]<b string=\"align left\" bolean=true>Left</b>[R]Right"
        var lexer = Lexer(source: source)
        lexer.tokenize()
        let tokens = lexer.tokens
        let expected = [
            Token(type: .ALIGNMENT, value: "C"),
            Token(type: .TEXT, value: "Center"),
            Token(type: .LINE_BREAK),
            Token(type: .ALIGNMENT, value: "L"),
            Token(type: .OPEN_TAG),
            Token(type: .TAG, value: "b"),
            Token(type: .ATTRIBUTE, value: "string"),
            Token(type: .ASSIGNMENT),
            Token(type: .STRING, value: "align left"),
            Token(type: .ATTRIBUTE, value: "bolean"),
            Token(type: .ASSIGNMENT),
            Token(type: .CONSTANT, value: "true"),
            Token(type: .CLOSE_TAG),
            Token(type: .TEXT, value: "Left"),
            Token(type: .OPEN_TAG),
            Token(type: .BACKSLASH),
            Token(type: .TAG, value: "b"),
            Token(type: .CLOSE_TAG),
            Token(type: .ALIGNMENT, value: "R"),
            Token(type: .TEXT, value: "Right")
        ]
        XCTAssertEqual(tokens.count, expected.count)
        for (index, token) in tokens.enumerated() {
            XCTAssertEqual(token, expected[index])
        }
    }
}
