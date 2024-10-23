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

    func testParser() throws {
        let source =
            "[C]<u><font size='big'>ORDER N°045</font></u>\n" +
            "[L]\n" +
            "[C]================================\n" +
            "[L]\n" +
            "[L]<b>BEAUTIFUL SHIRT</b>[R]9.99e\n" +
            "[L]  + Size : S\n" +
            "[L]\n" +
            "[L]<b>AWESOME HAT</b>[R]24.99e\n" +
            "[L]  + Size : 57/58\n" +
            "[L]\n" +
            "[C]--------------------------------\n" +
            "[R]TOTAL PRICE :[R]34.98e\n" +
            "[R]TAX :[R]4.23e\n" +
            "[L]\n" +
            "[C]================================\n" +
            "[L]\n" +
            "[L]<font size='tall'>Customer :</font>\n" +
            "[L]Raymond DUPONT\n" +
            "[L]5 rue des girafes\n" +
            "[L]31547 PERPETES\n" +
            "[L]Tel : +33801201456\n" +
            "[L]\n" +
            "[C]<barcode type='ean13' height='10'>831254784551</barcode>\n" +
            "[C]<qrcode size='20'>https://dantsu.com/</qrcode>"
        var lexer = Lexer(source: source)
        lexer.tokenize()
        let tokens = lexer.tokens
        let lines = parseTokens(tokens: tokens)
        for line in lines {
            print()
            for column in line.columns {
                print("[\(column.alignment)]", terminator: "")
                for tag in column.children {
                    tag.debug(2)
                }
            }
        }
    }
}
