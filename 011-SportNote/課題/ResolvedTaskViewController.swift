//
//  ResolvedTaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/30.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import SVProgressHUD

class ResolvedTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView?.reloadData()
        // テーブルビューを更新
        reloadTableView()
    }
    
    
    
    //MARK:- 変数の宣言
    var resolvedTaskDataArray = [TaskData]()    // 解決済みのTaskDataを格納する配列
    var indexPath:Int = 0                       // 行番号格納用
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //MARK:- テーブルビューの設定
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // タップしたセルの行番号を取得
        self.indexPath = indexPath.row
        
        // 詳細確認画面へ遷移
        performSegue(withIdentifier: "goResolvedTaskDetailViewController", sender: nil)
    }
    
    // 解決済みのTaskDataArrayの項目数を返却
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
        cell.detailTextLabel!.text = "原因：\(resolvedTaskData.getTaskCouse())"
        cell.detailTextLabel?.textColor = UIColor.systemGray
        
        return cell
    }
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goResolvedTaskDetailViewController" {
            // 表示する課題データを課題詳細確認画面へ渡す
            let resolvedTaskDetailViewController = segue.destination as! ResolvedTaskDetailViewController
            resolvedTaskDetailViewController.taskData = resolvedTaskDataArray[indexPath]
        }
    }
    
    // ResolvedTaskViewControllerに戻ったときの処理
    @IBAction func goToResolvedTaskViewController(_segue:UIStoryboardSegue) {
        
    }
    
    
    
    //MARK:- その他のメソッド
    
    // テーブルビューを更新するメソッド
    func reloadTableView() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
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
            
            // HUDで処理中を非表示
            SVProgressHUD.dismiss()
        }
    }

}
