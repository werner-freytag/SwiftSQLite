# SwiftSQLite

A lightweight Swift wrapper for sqlite3

## Example

```swift
import SwiftSQLite

let sqlite = try! SQLite(path: "test.db")

try! sqlite.query("CREATE TABLE test (id INTEGER PRIMARY KEY AUTOINCREMENT, value TEXT)")
try! sqlite.query("INSERT INTO test (value) VALUES (?)", arguments: ["😎"])
try! sqlite.query("INSERT INTO test (value) VALUES (?)", arguments: ["🤪"])

print("Last insert id: \(sqlite.lastInsertRowId)")

// -> Last insert id: 2

let result = try! sqlite.query("SELECT * FROM test")
print(result.fetchAll(column: "value") as [String])

// -> ["😎", "🤪"]

```

## Documentation

See unit tests for usage. Find a reference documentation in the **Documentation** directory. 
