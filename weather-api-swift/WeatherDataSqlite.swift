import UIKit
import SQLite3

class OneSqlite: NSObject {
    fileprivate var dbPointer: OpaquePointer?
    fileprivate let dbfile: String = "sample.db"
    
    // データベース（ファイル）作成
    func createOneDB() -> Bool {
        let filePath = try! FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(self.dbfile)
        
        self.dbPointer = nil
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath.path) {
            print("データベースファイルは既に存在しています: \(filePath.path)")
        } else {
            print("データベースファイルが作成されました: \(filePath.path)")
        }
        if sqlite3_open(filePath.path, &self.dbPointer) == SQLITE_OK {
            return true
        } else {
            print("Creating DB Error.")
            return false
        }
    }
    
    // テーブル作成
    func createOneTable() -> Bool {
        let createSql = """
            CREATE TABLE IF NOT EXISTS members (
                member_id INTEGER PRIMARY KEY AUTOINCREMENT,
                member_number TEXT NOT NULL,
                first_name TEXT,
                last_name TEXT,
                age TEXT
            );
        """
        var createTable: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbPointer, createSql, -1, &createTable, nil) == SQLITE_OK {
            if sqlite3_step(createTable) == SQLITE_DONE {
                return true
            } else {
                print("Error: Table creation failed")
                return false
            }
        } else {
            print("Error: Table creation SQL preparation failed")
            return false
        }
    }
    
    // データ挿入
    func insertOneTable() -> Bool {
        let insertSql = """
            INSERT INTO members
            (member_number, first_name, last_name, age)
            VALUES
            (?, ?, ?, ?);
        """
        var insertStmt: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbPointer, (insertSql as NSString).utf8String, -1, &insertStmt, nil) != SQLITE_OK {
            print("Insert statement preparation failed: \(sqlite3_errmsg(self.dbPointer))")
            return false
        }
        
        sqlite3_bind_text(insertStmt, 1, ("0001" as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertStmt, 2, ("tanaka" as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertStmt, 3, ("satoshi" as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertStmt, 4, ("35" as NSString).utf8String, -1, nil)
        
        if sqlite3_step(insertStmt) != SQLITE_DONE {
            print("Error inserting data: \(sqlite3_errmsg(self.dbPointer))")
            sqlite3_finalize(insertStmt)
            return false
        }
        
        sqlite3_finalize(insertStmt)
        return true
    }
    
    func printAllMembers(){
        let querySql = "SELECT * FROM members"
        var queryStmt: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbPointer, querySql, -1, &queryStmt, nil) == SQLITE_OK {
            while sqlite3_step(queryStmt) == SQLITE_ROW {
                let memberId = sqlite3_column_int(queryStmt, 0)
                let memberNumber = String(cString: sqlite3_column_text(queryStmt, 1))
                let firstName = String(cString: sqlite3_column_text(queryStmt, 2))
                let lastName = String(cString: sqlite3_column_text(queryStmt, 3))
                let age = String(cString: sqlite3_column_text(queryStmt, 4))
                print("ID: \(memberId), Member Number: \(memberNumber), Name: \(firstName) \(lastName), Age: \(age)")
            }
        } else {
            print("だめ")
        }
    }
}
