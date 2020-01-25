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

/// Result set of a SQLite query
public class SQLiteResultSet {
    private let sqlite3_stmt: OpaquePointer
    private let executeSqlite3: SQLiteExecute
    private var hasData = false

    private(set) lazy var columnNames: [String] = {
        (0 ..< sqlite3_column_count(sqlite3_stmt)).map { String(cString: sqlite3_column_name(sqlite3_stmt, Int32($0))) }
    }()

    internal init(pStmt: OpaquePointer, executeSqlite3: @escaping SQLiteExecute) throws {
        sqlite3_stmt = pStmt
        self.executeSqlite3 = executeSqlite3

        try step()
    }

    deinit {
        sqlite3_finalize(sqlite3_stmt)
    }

    // MARK: fetch

    /// Fetch next row as dictionary
    public func fetch() -> [String: Any?]? {
        guard let row = fetch(prepare: { columnNames.enumerated().map { ($1, value(at: $0)) } }) else { return nil }
        return Dictionary(uniqueKeysWithValues: row)
    }

    /// Fetch value of column at given index
    public func fetch<T>(index: Int) -> T {
        return fetch(prepare: { value(at: index) }) as! T
    }

    /// Fetch value of column with given name
    public func fetch<T>(column columnName: String) -> T {
        let index = self.index(of: columnName)!
        return fetch(prepare: { value(at: index) }) as! T
    }

    // MARK: fetchAll

    /// Fetch all rows as array of dictionaries
    public func fetchAll() -> [[String: Any?]] {
        return Array(iterate())
    }

    /// Fetch all values of column at given index
    public func fetchAll<T>(column columnName: String) -> [T] {
        return Array(iterate(column: columnName))
    }

    /// Fetch all values of column at given index
    public func fetchAll<T>(index: Int) -> [T] {
        return Array(iterate(index: index))
    }

    // MARK: iterate

    /// Returns sequence to iterate over all rows
    public func iterate() -> AnySequence<[String: Any?]> {
        return AnySequence {
            AnyIterator {
                self.fetch()
            }
        }
    }

    /// Returns sequence to iterate over all values of column at given index
    public func iterate<T>(index: Int) -> AnySequence<T> {
        return AnySequence {
            AnyIterator {
                self.fetch(index: index)
            }
        }
    }

    /// Returns sequence to iterate over all values of column with given name
    public func iterate<T>(column columnName: String) -> AnySequence<T> {
        guard let index = self.index(of: columnName) else { return AnySequence([]) }
        return iterate(index: index)
    }

    /// Step forward to next row
    public func step() throws {
        hasData = try executeSqlite3 { sqlite3_step(sqlite3_stmt) } == SQLITE_ROW
    }

    private func index(of columnName: String) -> Int? {
        guard !columnNames.isEmpty else { return nil } // no data returned
        guard let index = columnNames.firstIndex(of: columnName)
        else { assertionFailure("Unknown column name \"\(columnName)\""); return nil }
        return index
    }

    /// Forward to next row and return its data by applying prepare block to it
    private func fetch<T>(prepare: () -> T) -> T? {
        guard hasData else { return nil }

        defer { try! step() }
        return prepare()
    }

    // MARK: internal

    /// Returns a column of the current row
    private func value(at index: Int) -> Any? {
        guard (0 ..< columnNames.count).contains(index)
        else { assertionFailure("Out of range (\(index))"); return nil }

        let index = Int32(index)
        let type = sqlite3_column_type(sqlite3_stmt, index)

        switch type {
        case SQLITE_INTEGER:
            return Int(sqlite3_column_int64(sqlite3_stmt, index))

        case SQLITE_FLOAT:
            return Double(sqlite3_column_double(sqlite3_stmt, index))

        case SQLITE_BLOB:
            let dataSize = Int(sqlite3_column_bytes(sqlite3_stmt, index))
            guard let src = sqlite3_column_blob(sqlite3_stmt, index) else { assertionFailure(); return nil }
            var data = Data(count: dataSize)
            _ = data.withUnsafeMutableBytes { bytes in
                memcpy(bytes.baseAddress, src, dataSize)
            }
            return data

        case SQLITE_TEXT:
            guard let cString = sqlite3_column_text(sqlite3_stmt, index) else { assertionFailure(); return nil }
            return String(cString: cString)

        case SQLITE_NULL:
            return nil

        default:
            assertionFailure("Unknown type (\(type))")
            return nil
        }
    }
}
