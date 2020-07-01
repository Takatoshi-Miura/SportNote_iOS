//
//  ResolvedTaskDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/30.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import SVProgressHUD

class ResolvedTaskDetailViewController: UIViewController,UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.delegate = self
        
        // 受け取った課題データを表示する
        printTaskData(taskData)
        
        // TaskViewControllerから受け取った課題データの対策を取得
        measuresTitleArray = taskData.getAllMeasuresTitle()
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 課題データ格納用
    var taskData = TaskData()
    
    // 対策タイトルの格納用
    var measuresTitleArray:[String] = []

    
    
    // 未解決に戻すボタンの処理
    @IBAction func unsolvedButton(_ sender: Any) {
        // 未解決にする
        taskData.changeAchievement()
        
        // 通知
        SVProgressHUD.showSuccess(withStatus: "未解決にしました")
    }
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is ResolvedTaskViewController {
            // 課題データを更新
            taskData.updateTaskData()
        }
    }
    
    
    // セルの内容を表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        taskTitleTextField.text = taskData.getTaskTitle()
        taskCauseTextView.text  = taskData.getTaskCouse()
    }
    
    
    // 対策の数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.getMeasuresCount()
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "measuresCell", for: indexPath)
        
        //行番号に合った対策データをラベルに表示する
        cell.textLabel!.text = taskData.getMeasuresTitle(indexPath.row)
        cell.detailTextLabel?.text = taskData.getMeasuresEffectiveness(indexPath.row)
        
        return cell
    }


}
