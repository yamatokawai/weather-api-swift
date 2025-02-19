import UIKit
import SQLite3

class OneSqlite: NSObject {
    fileprivate var dbPointer: OpaquePointer?
    fileprivate let dbfile: String = "sample.db"
    
    // データベース（ファイル）作成
    func createOneDB() -> Bool {
        sqlite3_close(self.dbPointer)
        self.dbPointer = nil
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
    
    
    /// データベース初期化
    /// - Returns: 初期化処理の結果
    func deleteDatabase() -> Bool {
        let filePath = try! FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false
        ).appendingPathComponent(self.dbfile)
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.removeItem(at: filePath)
                print("データベースファイルを削除しました: \(filePath.path)")
                self.dbPointer = nil
                return true
            } catch {
                print("データベース削除エラー: \(error)")
                return false
            }
        } else {
            print("データベースファイルが存在しません")
            return false
        }
    }

    
    // テーブル作成
    func createOneTable() -> Bool {
        let createSql = """
            CREATE TABLE IF NOT EXISTS members (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                temperature TEXT,
                weather TEXT
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
    func insertOneTable(temperature: String, weather: String) -> Bool {
        let insertSql = """
            INSERT INTO members
            (temperature, weather)
            VALUES
            (?, ?);
        """
        var insertStmt: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbPointer, (insertSql as NSString).utf8String, -1, &insertStmt, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(self.dbPointer))
            print("insert error 1: \(errorMessage)")
            return false
        }
        
        sqlite3_bind_text(insertStmt, 1, (temperature as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertStmt, 2, (weather as NSString).utf8String, -1, nil)
        
        if sqlite3_step(insertStmt) != SQLITE_DONE {
            print("insert error 2")
            sqlite3_finalize(insertStmt)
            return false
        }
        
        sqlite3_finalize(insertStmt)
        return true
    }
    
    
    
    /// テーブル削除
    /// - Returns: テーブル削除結果
    func deleteOneTable() -> Bool {
        let deleteSql = "DELETE FROM members";
        var deleteStmt: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.dbPointer, (deleteSql as NSString).utf8String, -1, &deleteStmt, nil) != SQLITE_OK {
            print("sqlite3_prepare_v2 error")
            return false
        }
        
        sqlite3_bind_int(deleteStmt, 1, 0)
        
        if sqlite3_step(deleteStmt) != SQLITE_DONE {
            print("sqlite3_step error")
            sqlite3_finalize(deleteStmt)
            return false
        }
        
        sqlite3_finalize(deleteStmt)
        return true
    }
    
    
    /// テーブル状況確認用関数
    func printAllMembers(){
        let querySql = "SELECT * FROM members"
        var queryStmt: OpaquePointer? = nil
        if sqlite3_prepare_v2(self.dbPointer, querySql, -1, &queryStmt, nil) == SQLITE_OK {
            while sqlite3_step(queryStmt) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStmt, 0)
                let temperature = String(cString: sqlite3_column_text(queryStmt, 1))
                let weather = String(cString: sqlite3_column_text(queryStmt, 2))
                print("ID: \(id), 気温: \(temperature), 天気: \(weather)")
            }
        } else {
            print("だめ")
        }
    }
}
