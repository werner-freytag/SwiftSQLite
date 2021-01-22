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

#if os(iOS)
    import UIKit.UIApplication
    import UIKit.UIDevice
#endif

/// SQLite database handle
public class SQLite {
    public private(set) var path: String
    private var sqlite3: OpaquePointer!

    /// If set to true, all queries are printed
    public var traceExecution = false

    /// Number of trials before throwing TooBusy error
    public var maxBusyRetries = 10

    /// Errors that can occur
    public enum Error: Swift.Error {
        case TooBusy
        case InvalidType
        case Failure(code: Int32, message: String)

        case QueryFailure(error: Swift.Error, query: String)
        case ArgumentFailure(error: Swift.Error, argument: SQLiteValue?, index: Int32)
    }

    #if os(iOS)
        private weak var transactionThread: Thread?
        private var transactionTask: UIBackgroundTaskIdentifier = .invalid
    #endif

    public var isInTransaction = false {
        willSet {
            #if os(iOS)
                guard #available(iOS 4.0, *), newValue != isInTransaction, UIDevice.current.isMultitaskingSupported else { return }
                newValue ? startTransactionTask() : endTransactionTask()
            #endif
        }
    }

    /// Returns the rowid of the most recent successful [INSERT]
    public var lastInsertRowId: Int64 {
        return sqlite3_last_insert_rowid(sqlite3)
    }

    public init(path: String) throws {
        self.path = path
        try open()
    }

    deinit {
        try? close()
    }

    /// Called implicitely in init
    public func open() throws {
        try executeSqlite3 {
            sqlite3_open_v2(path, &sqlite3, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)
        }
    }

    /// Called implicitely in deinit
    public func close() throws {
        try executeSqlite3 { sqlite3_close(sqlite3) }
    }

    /// Prepares a query, binds arguments to it and execute it
    @discardableResult
    public func query(_ query: String, arguments: [SQLiteValue?] = []) throws -> SQLiteResultSet {
        traceLog("execute query: \(query)")
        let statement = try prepare(query)

        assert(arguments.count == statement.bindParameterCount)

        for (index, argument) in arguments.enumerated() {
            traceLog("arg #\(index): \(argument ?? "nil")")
            try statement.bind(argument: argument, toColumn: index)
        }

        return try statement.execute()
    }

    public func prepare(_ query: String) throws -> SQLiteStatement {
        var sqlite3_stmt: OpaquePointer!

        do {
            try executeSqlite3 { sqlite3_prepare_v2(sqlite3, query, -1, &sqlite3_stmt, nil) }
        } catch {
            sqlite3_finalize(sqlite3_stmt)
            throw Error.QueryFailure(error: error, query: query)
        }

        return SQLiteStatement(pStmt: sqlite3_stmt, executeSqlite3: executeSqlite3(_:))
    }

    @discardableResult
    internal func executeSqlite3(_ exec: () throws -> Int32) throws -> Int32 {
        for _ in 0 ..< maxBusyRetries {
            let rc = try exec()
            switch rc {
            case SQLITE_OK, SQLITE_DONE, SQLITE_ROW:
                return rc

            case SQLITE_BUSY:
                Thread.sleep(forTimeInterval: 0.02)

            default:
                throw SQLite.Error.Failure(code: rc, message: String(cString: sqlite3_errmsg(sqlite3)))
            }
        }

        throw SQLite.Error.TooBusy
    }

    // MARK: Logging

    private func traceLog(_ output: String) {
        if traceExecution {
            NSLog(output)
        }
    }

    // MARK: Transaction

    public func rollback() throws {
        guard isInTransaction else { return assertionFailure("Transaction rolled back though none in progress") }

        try query("ROLLBACK TRANSACTION")
        isInTransaction = false
        #if os(iOS)
            transactionThread = nil
        #endif
    }

    public func commit() throws {
        guard isInTransaction else { return assertionFailure("Transaction commited though none in progress") }

        try query("COMMIT TRANSACTION")
        isInTransaction = false
        #if os(iOS)
            transactionThread = nil
        #endif
    }

    public func beginTransaction() throws {
        guard !isInTransaction else { return assertionFailure("Transaction started while another one already in progress") }

        try query("BEGIN TRANSACTION")
        isInTransaction = true
    }

    /// Executes the given block within a beginTransaction/commit block or calls rollback on errors
    public func performTransaction(_ block: () throws -> Void) throws {
        do {
            try beginTransaction()
            try block()
            try commit()
        } catch {
            try rollback()
            throw error
        }
    }

    #if os(iOS)
        @available(iOS 4.0, *)
        private func startTransactionTask() {
            transactionTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                UIApplication.shared.endBackgroundTask(self.transactionTask)
                self.transactionTask = .invalid
            })
        }

        @available(iOS 4.0, *)
        private func endTransactionTask() {
            if transactionTask != .invalid {
                UIApplication.shared.endBackgroundTask(transactionTask)
                transactionTask = .invalid
            }
        }
    #endif
}

internal typealias SQLiteExecute = (_ exec: () throws -> Int32) throws -> Int32
