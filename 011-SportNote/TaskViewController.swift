//
//  TaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import SVProgressHUD

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // TaskDataを格納した配列
    var taskDataArray = [TaskData]()
    
    // テーブルビュー
    @IBOutlet weak var taskTableView: UITableView!
    
    
    // HomeViewControllerが呼ばれたときの処理
    override func viewWillAppear(_ animated: Bool) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // データベースの課題データを取得
        let databaseTaskData = TaskData()
        databaseTaskData.loadDatabase()
        
        // 課題データの受け取り
        self.taskDataArray = []
        self.taskDataArray = databaseTaskData.taskDataArray
        
        // HUDを非表示
        SVProgressHUD.dismiss()
    }
    
    
    // ＋ボタンの処理
    @IBAction func addButton(_ sender: Any) {
        // 課題追加画面に遷移
        self.performSegue(withIdentifier: "goAddTaskViewController", sender: nil)
    }
    
    
    // TaskDataArray配列の長さ(項目の数)を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskDataArray.count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskViewCell", for: indexPath)
        //行番号に合ったToDoの情報を取得
        
        
        return cell
    }


}
