//
//  ResolvedTaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/30.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class ResolvedTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // ResolvedTaskViewControllerが呼ばれたときの処理
    override func viewWillAppear(_ animated: Bool) {
        self.tableView?.reloadData()
        // テーブルビューを更新
        reloadTableView()
    }
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 解決済みのTaskDataを格納する配列
    var resolvedTaskDataArray = [TaskData]()
    
    
    // テーブルビューを更新するメソッド
    func reloadTableView() {
        // データベースの課題データを取得
        let databaseTaskData = TaskData()
        databaseTaskData.loadResolvedTaskData()
        
        // データの取得が終わるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            // 課題データの受け取り
            self.resolvedTaskDataArray = []
            self.resolvedTaskDataArray = databaseTaskData.taskDataArray
        
            // テーブルビューの更新
            self.tableView?.reloadData()
        }
    }
    
    
    
    // 解決済みのTaskDataArrayの項目の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resolvedTaskDataArray.count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 未解決の課題セルを取得する
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "resolvedTaskCell", for: indexPath)
        
        // 行番号に合った課題データをラベルに表示する
        let resolvedTaskData = resolvedTaskDataArray[indexPath.row]
        cell.textLabel!.text = resolvedTaskData.getTaskTitle()
        cell.detailTextLabel!.text = resolvedTaskData.getTaskCouse()
        
        return cell
    }

}
