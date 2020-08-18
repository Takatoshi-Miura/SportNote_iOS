//
//  ResolvedTaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/30.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ResolvedTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // テーブルビューを更新
        reloadTaskData()
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
        // 未解決の課題セルを返却
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "resolvedTaskCell", for: indexPath)
        cell.textLabel!.text = resolvedTaskDataArray[indexPath.row].getTaskTitle()
        cell.detailTextLabel!.text = "原因：\(resolvedTaskDataArray[indexPath.row].getTaskCouse())"
        cell.detailTextLabel?.textColor = UIColor.systemGray
        return cell
    }
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goResolvedTaskDetailViewController" {
            // 表示する課題データを課題詳細確認画面へ渡す
            let taskDetailViewController = segue.destination as! TaskDetailViewController
            taskDetailViewController.taskData = resolvedTaskDataArray[indexPath]
            taskDetailViewController.previousControllerName = "ResolvedTaskViewController"
        }
    }
    
    // ResolvedTaskViewControllerに戻ったときの処理
    @IBAction func goToResolvedTaskViewController(_segue:UIStoryboardSegue) {
    }
    
    
    
    //MARK:- データベース関連
    
    // 課題データを取得するメソッド
    func reloadTaskData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 配列の初期化
        resolvedTaskDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // ユーザーの解決済み課題データ取得
        // ログインユーザーの課題データで、かつisDeletedがfalseの課題を取得
        // 課題画面にて、古い課題を下、新しい課題を上に表示させるため、taskIDの降順にソートする
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .whereField("taskAchievement", isEqualTo: true)
            .order(by: "taskID", descending: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let taskDataCollection = document.data()
                
                        // 取得データを基に、課題データを作成
                        let databaseTaskData = TaskData()
                        databaseTaskData.setTaskID(taskDataCollection["taskID"] as! Int)
                        databaseTaskData.setTaskTitle(taskDataCollection["taskTitle"] as! String)
                        databaseTaskData.setTaskCause(taskDataCollection["taskCause"] as! String)
                        databaseTaskData.setTaskAchievement(taskDataCollection["taskAchievement"] as! Bool)
                        databaseTaskData.setIsDeleted(taskDataCollection["isDeleted"] as! Bool)
                        databaseTaskData.setUserID(taskDataCollection["userID"] as! String)
                        databaseTaskData.setCreated_at(taskDataCollection["created_at"] as! String)
                        databaseTaskData.setUpdated_at(taskDataCollection["updated_at"] as! String)
                        databaseTaskData.setMeasuresData(taskDataCollection["measuresData"] as! [String:[[String:Int]]])
                        databaseTaskData.setMeasuresPriority(taskDataCollection["measuresPriority"] as! String)
                        
                        // 課題データを格納
                        self.resolvedTaskDataArray.append(databaseTaskData)
                    }
                    // テーブルビューの更新
                    self.tableView?.reloadData()
                    
                    // HUDで処理中を非表示
                    SVProgressHUD.dismiss()
                }
            }
    }

}
