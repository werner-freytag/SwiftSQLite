@testable import SwiftSQLite
import XCTest

class SQLiteEscapableTests: XCTestCase {
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

    func testStringSqliteEscaped() {
        XCTAssertEqual("test".sqliteEscaped, "'test'")
        XCTAssertEqual("\"test".sqliteEscaped, "'\"test'")
        XCTAssertEqual("'test'".sqliteEscaped, "'''test'''")
        XCTAssertEqual("'\"test'".sqliteEscaped, "'''\"test'''")
        XCTAssertEqual("'te\'st'".sqliteEscaped, "'''te''st'''")
        XCTAssertEqual("te''te".sqliteEscaped, "'te''''te'")
    }

    func testBoolSqliteEscaped() {
        XCTAssertEqual("1", true.sqliteEscaped)
        XCTAssertEqual("0", false.sqliteEscaped)
    }

    func testIntSqliteEscaped() {
        XCTAssertEqual("12345", 12345.sqliteEscaped)
        XCTAssertEqual("-12345", (-12345).sqliteEscaped)
    }

    func testDoubleSqliteEscaped() {
        XCTAssertEqual("123.450000", 123.45.sqliteEscaped)
        XCTAssertEqual("-123.450000", (-123.45).sqliteEscaped)
    }
}
