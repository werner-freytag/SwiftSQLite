@testable import SwiftSQLite
import XCTest

class SQLiteResultSetTests: XCTestCase {
    private var sqlite: SQLite!

    override func setUp() {
        let uuid = UUID().uuidString
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(uuid).path

        sqlite = try! SQLite(path: tempPath)

        try! sqlite.query("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, value TEXT)")
        try! sqlite.query("INSERT INTO test (value) VALUES (?)", arguments: ["😎"])
        try! sqlite.query("INSERT INTO test (value) VALUES (?)", arguments: ["🤪"])
    }

    override func tearDown() {
        try! sqlite.close()
        try! FileManager.default.removeItem(atPath: sqlite.path)
    }

    func testColumnNames() {
        let result = try! sqlite.query("SELECT * FROM test")
        XCTAssertEqual(["id", "value"], result.columnNames)
    }

    func testFetch() {
        let result = try! sqlite.query("SELECT * FROM test")

        var row: [String: Any?]

        row = result.fetch()!
        XCTAssertEqual(1, row["id"] as? Int)
        XCTAssertEqual("😎", row["value"] as? String)

        row = result.fetch()!
        XCTAssertEqual(2, row["id"] as? Int)
        XCTAssertEqual("🤪", row["value"] as? String)
    }

    func testFetchByIndex() {
        let result = try! sqlite.query("SELECT * FROM test")

        XCTAssertEqual(1, result.fetch(index: 0))
        XCTAssertEqual(2, result.fetch(index: 0))
    }

    func testFetchByColumn() {
        let result = try! sqlite.query("SELECT * FROM test")

        XCTAssertEqual("😎", result.fetch(column: "value"))
        XCTAssertEqual("🤪", result.fetch(column: "value"))
    }

    func testFetchAll() {
        let result = try! sqlite.query("SELECT * FROM test")

        let rows = result.fetchAll()
        XCTAssertEqual(1, rows[0]["id"] as? Int)
        XCTAssertEqual("😎", rows[0]["value"] as? String)
        XCTAssertEqual(2, rows[1]["id"] as? Int)
        XCTAssertEqual("🤪", rows[1]["value"] as? String)
    }

    func testFetchAllByIndex() {
        let result = try! sqlite.query("SELECT * FROM test")

        XCTAssertEqual([1, 2], result.fetchAll(index: 0))
    }

    func testFetchAllByColumn() {
        let result = try! sqlite.query("SELECT * FROM test")

        XCTAssertEqual(["😎", "🤪"], result.fetchAll(column: "value"))
    }

    func testIterate() {
        let result = try! sqlite.query("SELECT * FROM test")

        var expected = [["id": 1, "value": "😎"], ["id": 2, "value": "🤪"]].makeIterator()

        for row in result.iterate() {
            let expectedRow = expected.next()!
            XCTAssertEqual(expectedRow["id"] as? Int, row["id"] as? Int)
            XCTAssertEqual(expectedRow["value"] as? String, row["value"] as? String)
        }
    }

    func testIterateIndex() {
        let result = try! sqlite.query("SELECT * FROM test")

        var expected = [1, 2].makeIterator()

        for value in result.iterate(index: 0) as AnySequence<Int> {
            let expectedValue = expected.next()!
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testIterateColumn() {
        let result = try! sqlite.query("SELECT * FROM test")

        var expected = ["😎", "🤪"].makeIterator()

        for value in result.iterate(column: "value") as AnySequence<String> {
            let expectedValue = expected.next()!
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testStep() {
        let result = try! sqlite.query("SELECT * FROM test")
        try! result.step()

        XCTAssertEqual("🤪", result.fetch(column: "value"))
    }

    static var allTests = [
        ("testColumnNames", testColumnNames),
        ("testFetch", testFetch),
        ("testFetchByIndex", testFetchByIndex),
        ("testFetchByColumn", testFetchByColumn),
        ("testFetchAll", testFetchAll),
        ("testFetchAllByIndex", testFetchAllByIndex),
        ("testFetchAllByColumn", testFetchAllByColumn),
        ("testIterate", testIterate),
        ("testIterateIndex", testIterateIndex),
        ("testIterateColumn", testIterateColumn),
        ("testStep", testStep),
    ]
}
