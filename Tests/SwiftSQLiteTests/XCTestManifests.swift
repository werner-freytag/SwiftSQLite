import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase(SQLiteEscapableTests.allTests),
            testCase(SQLiteResultSetTests.allTests),
            testCase(SQLiteStatementTests.allTests),
            testCase(SQLiteTests.allTests),
        ]
    }
#endif
