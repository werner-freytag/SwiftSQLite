@testable import SwiftSQLite
import XCTest

class SQLiteStatementTests: XCTestCase {
    private var sqlite: SQLite!

    override func setUp() {
        let uuid = UUID().uuidString
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(uuid).path

        sqlite = try! SQLite(path: tempPath)
    }

    override func tearDown() {
        try! sqlite.close()
        try! FileManager.default.removeItem(atPath: sqlite.path)
    }

    func testExecute() {
        let statement = try! sqlite.prepare("SELECT 1")
        let result = try! statement.execute()

        XCTAssertNotNil(result.fetch())
    }

    func testBind() {
        let statement = try! sqlite.prepare("SELECT ?")
        try! statement.bind(argument: 1, toColumn: 0)
        let result = try! statement.execute()

        XCTAssertNotNil(result.fetch())
    }

    static var allTests = [
        ("testExecute", testExecute),
        ("testBind", testBind),
    ]
}
