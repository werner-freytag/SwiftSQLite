// The MIT License
//
// Copyright 2019 Werner Freytag
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import SQLite3

/// Prepared SQLite statement
public class SQLiteStatement {
    private let sqlite3_stmt: OpaquePointer
    private let executeSqlite3: SQLiteExecute

    private(set) lazy var columnNames: [String] = {
        (0 ..< sqlite3_column_count(sqlite3_stmt)).map { String(cString: sqlite3_column_name(sqlite3_stmt, Int32($0))) }
    }()

    private let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    internal init(pStmt: OpaquePointer, executeSqlite3: @escaping SQLiteExecute) {
        sqlite3_stmt = pStmt
        self.executeSqlite3 = executeSqlite3
    }

    /// Bind a value to a column
    public func bind(argument: SQLiteValue?, toColumn index: Int) throws {
        let index = Int32(index + 1)

        do {
            _ = try executeSqlite3 {
                switch argument {
                case let data as Data:
                    return data.withUnsafeBytes { bytes in
                        sqlite3_bind_blob(sqlite3_stmt, index, bytes.baseAddress, Int32(data.count), SQLITE_STATIC)
                    }

                case let bool as Bool:
                    return sqlite3_bind_int(sqlite3_stmt, index, bool ? 1 : 0)

                case let int as Int:
                    return sqlite3_bind_int64(sqlite3_stmt, index, Int64(int))

                case let float as Float:
                    return sqlite3_bind_double(sqlite3_stmt, index, Double(float))

                case let double as Double:
                    return sqlite3_bind_double(sqlite3_stmt, index, double)

                case let text as String:
                    return sqlite3_bind_text(sqlite3_stmt, index, text, -1, SQLITE_TRANSIENT)

                case nil:
                    return sqlite3_bind_null(sqlite3_stmt, index)

                default:
                    throw SQLite.Error.InvalidType
                }
            }
        } catch {
            throw SQLite.Error.ArgumentFailure(error: error, argument: argument, index: index)
        }
    }

    public var bindParameterCount: Int { Int(sqlite3_bind_parameter_count(sqlite3_stmt)) }

    /// Execute statement and return result set
    @discardableResult
    public func execute() throws -> SQLiteResultSet {
        return try SQLiteResultSet(pStmt: sqlite3_stmt, executeSqlite3: executeSqlite3)
    }
}
