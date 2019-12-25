import XCTest

import SwiftSQLiteTests

var tests = [XCTestCaseEntry]()
tests += SQLiteEscapableTests.allTests()
tests += SQLiteResultSetTests.allTests()
tests += SQLiteStatementTests.allTests()
tests += SQLiteTests.allTests()
XCTMain(tests)
