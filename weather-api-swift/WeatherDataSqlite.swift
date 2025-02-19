import UIKit
import SQLite3

class OneSqlite: NSObject {
    fileprivate var dbPointer: OpaquePointer?
    fileprivate let dbfile: String = "sample.db"
    
    // データベース（ファイル）作成
    func createOneDB() -> Bool {
        sqlite3_close(self.dbPointer) //開きっぱなしだとリソースの無駄遣いになるため、前回開いたDBを一度閉じる（作り直しではない）
        self.dbPointer = nil // DBの住所
        // DBの保存場所（パス）を取得
        let filePath = try! FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(self.dbfile)
        let fileManager = FileManager.default //ファイル操作をするためのクラス（defaultはインスタンス）
        // データベースファイルが存在するかチェック
        if fileManager.fileExists(atPath: filePath.path) {
            print("データベースファイルは既に存在しています: \(filePath.path)")
        } else {
            print("データベースファイルが作成されました: \(filePath.path)")
        }
        // DBを開く　or　DB作成 (ファイルへのパス, アクセス用ポインタ)
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
                try fileManager.removeItem(at: filePath) // パスに存在するDBを削除
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
        // SQL文：テーブルが存在しない場合のみ作成するよう指示
        let createSql = """
            CREATE TABLE IF NOT EXISTS members (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                temperature TEXT,
                weather TEXT
            );
        """
        
        var createTable: OpaquePointer? = nil
        
        // SQL文をコンパイルして準備
        // 引数(DBへのポインタ, 実行するSQL分, SQL分のバイト数, SQLstmtをの準備用ポインタ, 残り(複数行ある場合など)のSQL文)
        if sqlite3_prepare_v2(self.dbPointer, createSql, -1, &createTable, nil) == SQLITE_OK {
            // 準備成功したら実行
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
        // SQL文：membersテーブルに追加するよう指示
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
    
    
    /// テーブル情報取得（状況確認用関数）
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
