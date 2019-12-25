@testable import SwiftSQLite
import XCTest

class SQLiteTests: XCTestCase {
    private var sqlite: SQLite!

    override func setUp() {
        let uuid = UUID().uuidString
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(uuid).path

        sqlite = try! SQLite(path: tempPath)
    }

    override func tearDown() {
        let path = sqlite.path
        sqlite = nil

        try? FileManager.default.removeItem(atPath: path)
    }

    func testQuery() {
        let result = try! sqlite.query("SELECT 1")

        XCTAssertNotNil(result.fetch())
    }

    func testQueryWithArguments() {
        let result = try! sqlite.query("SELECT ? nil, ? bool, ? int, ? double, ? float, ? string, ? data", arguments: [nil, true, 1, 0.0, Float(0.0), "example", "data".data(using: .utf8)])

        XCTAssertNotNil(result.fetch())
    }

    func testQueryWithInvalidArgument() {
        var result: SQLiteResultSet!
        do {
            result = try sqlite.query("SELECT ?", arguments: [CGPoint(x: 0, y: 0)])
        } catch {}

        XCTAssertNil(result)
    }

    func testQueryWithNilArgument() {
        let result = try! sqlite.query("SELECT ?", arguments: [nil])

        XCTAssertNotNil(result.fetch())
    }

    func testPrepareAndExecute() {
        let statement = try! sqlite.prepare("SELECT 1")
        let result = try! statement.execute()

        XCTAssertNotNil(result.fetch())
    }

    func testLastInsertRowId() {
        try! sqlite.query("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT)")
        try! sqlite.query("INSERT INTO test (id) VALUES (NULL)")

        XCTAssertEqual(1, sqlite.lastInsertRowId)
    }

    func testTransaction() {
        try! sqlite.query("CREATE TABLE test (id INTEGER)")

        try! sqlite.beginTransaction()
        try! sqlite.query("INSERT INTO test(id) VALUES(1)")
        try! sqlite.rollback()

        var result: SQLiteResultSet!
        result = try! sqlite.query("SELECT * FROM test")
        XCTAssertNil(result.fetch())

        try! sqlite.beginTransaction()
        try! sqlite.query("INSERT INTO test (id) VALUES (1)")
        try! sqlite.commit()

        result = try! sqlite.query("SELECT * FROM test")
        XCTAssertNotNil(result.fetch())
    }

    func testPerformTransaction() {
        try! sqlite.query("CREATE TABLE test (id INTEGER)")

        var result: SQLiteResultSet!
        try? sqlite.performTransaction {
            result = try! sqlite.query("INSERT INTO test(id) VALUES(1)")
            throw SQLite.Error.InvalidType
        }
        result = try! sqlite.query("SELECT * FROM test")
        XCTAssertNil(result.fetch())

        try! sqlite.performTransaction {
            try! sqlite.query("INSERT INTO test (id) VALUES (1)")
        }
        result = try! sqlite.query("SELECT * FROM test")
        XCTAssertNotNil(result.fetch())
    }

    static var allTests = [
        ("testQuery", testQuery),
        ("testQueryWithArguments", testQueryWithArguments),
        ("testQueryWithInvalidArgument", testQueryWithInvalidArgument),
        ("testQueryWithNilArgument", testQueryWithNilArgument),
        ("testPrepareAndExecute", testPrepareAndExecute),
        ("testLastInsertRowId", testLastInsertRowId),
        ("testTransaction", testTransaction),
        ("testPerformTransaction", testPerformTransaction),
    ]
}
