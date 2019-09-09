// The MIT License
//
// Copyright 2017-2019 Werner Freytag
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

/// Protocol for escaping values for usage in queries
public protocol SQLiteEscapable {
    /// Escape values for usage in queries
    var sqliteEscaped: String { get }
}

extension String: SQLiteEscapable {
    public var sqliteEscaped: String {
        var result = "''"

        let validUTF8 = cString(using: .utf8)!
        validUTF8.withUnsafeBufferPointer { ptr in
            let cstr = sqlite3_vmprintf("%Q", getVaList([ptr.baseAddress!]))
            result = String(cString: cstr!)
            sqlite3_free(cstr)
        }

        return result
    }
}

extension Bool: SQLiteEscapable {
    public var sqliteEscaped: String {
        let cstr = sqlite3_vmprintf("%d", getVaList([self]))
        let result = String(cString: cstr!)
        sqlite3_free(cstr)

        return result
    }
}

extension Int: SQLiteEscapable {
    public var sqliteEscaped: String {
        let cstr = sqlite3_vmprintf("%d", getVaList([self]))
        let result = String(cString: cstr!)
        sqlite3_free(cstr)

        return result
    }
}

extension Double: SQLiteEscapable {
    public var sqliteEscaped: String {
        let cstr = sqlite3_vmprintf("%f", getVaList([self]))
        let result = String(cString: cstr!)
        sqlite3_free(cstr)

        return result
    }
}
