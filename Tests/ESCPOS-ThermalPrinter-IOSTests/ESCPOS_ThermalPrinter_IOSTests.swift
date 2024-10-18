import XCTest
@testable import ESCPOS_ThermalPrinter_IOS

final class ESCPOS_ThermalPrinter_IOSTests: XCTestCase {
    func testGetRegexAlingTags() throws {
        let source = "[C]Center\n[L]<b class=\"align left\">Left</b>[R]Right"
        var lexer = Lexer(source: source)
        lexer.tokenize()
        print("Plain text:\n\(lexer.plainText())")
        let tokens = lexer.tokens
        print("\nTokens:")
        for token in tokens {
            token.debug()
        }
        print("\n")
    }
}
