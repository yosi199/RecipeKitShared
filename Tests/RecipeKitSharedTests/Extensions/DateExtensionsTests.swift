import XCTest
@testable import RecipeKitShared

final class DateExtensionsTests: XCTestCase {
    
    func testDisplayFormat() {
        let date = Date()
        let formatted = date.displayFormat
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testRelativeFormat() {
        let date = Date()
        let formatted = date.relativeFormat
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testShortDateFormat() {
        let date = Date()
        let formatted = date.shortDateFormat
        XCTAssertFalse(formatted.isEmpty)
    }
}
