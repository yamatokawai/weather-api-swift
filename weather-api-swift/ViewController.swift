import UIKit
class ViewController: UIViewController {
    fileprivate var oneSqlite : OneSqlite!
    override func viewDidLoad() {
        super.viewDidLoad()
        getDBPath()
        //sqliteデータベース作成
        self.oneSqlite = OneSqlite()
        if (self.oneSqlite.createOneDB())
        {
            if (self.oneSqlite.createOneTable())
            {
                print("テーブル作成成功")
                if(self.oneSqlite.insertOneTable()){
                    print("データ作成成功")
                    self.oneSqlite.printAllMembers()
                }
            }
        }
    }
    
    func getDBPath() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dbPath = paths.first!.appendingPathComponent("mydatabase.sqlite").path
        print("データベースのパス: \(dbPath)")
    }
}
