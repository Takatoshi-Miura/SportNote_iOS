//
//  ResolvedTaskDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/30.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ResolvedTaskDetailViewController: UIViewController,UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.delegate = self
        
        // 受け取った課題データを表示する
        printTaskData(taskData)
        
        // TaskViewControllerから受け取った課題データの対策を取得
        measuresTitleArray = taskData.getMeasuresTitleArray()
        
        // テキストビューの枠線付け
        taskCauseTextView.layer.borderColor = UIColor.systemGray.cgColor
        taskCauseTextView.layer.borderWidth = 1.0
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    
    
    //MARK:- 変数の宣言
    var taskData = TaskData()               // 課題データ格納用
    var measuresTitleArray:[String] = []    // 対策タイトルの格納用
    var indexPath:Int = 0                   // 行番号格納用
    var unsolvedButtonTap:Bool = false      // 未解決ボタンのタップ判定
    
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 未解決に戻すボタンの処理
    @IBAction func unsolvedButton(_ sender: Any) {
        unsolvedButtonTap = true
        
        // 未解決にする
        taskData.changeAchievement()
        
        // データ更新
        updateTaskData()
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    // 対策の数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.getMeasuresTitleArray().count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "measuresCell", for: indexPath)
        
        //行番号に合った対策データをラベルに表示する
        cell.textLabel!.text = taskData.getMeasuresTitleArray()[indexPath.row]
        
        // 有効性コメントを取得
        if taskData.getMeasuresEffectivenessArray(at: indexPath.row).count == 0 {
            cell.detailTextLabel?.text = "有効性："
        } else {
            cell.detailTextLabel?.text = "有効性：\(self.taskData.getMeasuresEffectiveness(at: indexPath.row))"
        }
        cell.detailTextLabel?.textColor = UIColor.systemGray
        return cell
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // タップしたセルの行番号を取得
        self.indexPath = indexPath.row
        
        // 課題詳細確認画面へ遷移
        performSegue(withIdentifier: "goResolvedMeasuresDetailViewController", sender: nil)
    }
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goResolvedMeasuresDetailViewController" {
            // 課題データを対策詳細確認画面へ渡す
            let resolvedMeasuresDetailViewController = segue.destination as! ResolvedMeasuresDetailViewController
            resolvedMeasuresDetailViewController.taskData = taskData
            resolvedMeasuresDetailViewController.indexPath = indexPath
        }
    }
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is ResolvedTaskViewController {
            // 課題データを更新
            updateTaskData()
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // セルの内容を表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        taskTitleTextField.text = taskData.getTaskTitle()
        taskCauseTextView.text  = taskData.getTaskCouse()
    }
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }

    // Firebaseの課題データを更新するメソッド
    func updateTaskData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 課題データを更新
        taskData.setTaskTitle(taskTitleTextField.text!)
        taskData.setTaskCause(taskCauseTextView.text!)
        
        // 更新日時を現在時刻にする
        taskData.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let database = db.collection("TaskData").document("\(Auth.auth().currentUser!.uid)_\(self.taskData.getTaskID())")

        // 変更する可能性のあるデータのみ更新
        database.updateData([
            "taskTitle"      : taskData.getTaskTitle(),
            "taskCause"      : taskData.getTaskCouse(),
            "taskAchievement": taskData.getTaskAchievement(),
            "isDeleted"      : taskData.getIsDeleted(),
            "updated_at"     : taskData.getUpdated_at(),
            "measuresData"   : taskData.getMeasuresData(),
            "measuresPriority" : taskData.getMeasuresPriority()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("課題データを更新しました")
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                
                // 解決済みボタンをタップした場合
                if self.unsolvedButtonTap == true {
                    // 前の画面に戻る
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

}
