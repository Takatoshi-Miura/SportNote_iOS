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
        measuresTitleArray = taskData.getAllMeasuresTitle()
        
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

    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 未解決に戻すボタンの処理
    @IBAction func unsolvedButton(_ sender: Any) {
        // 未解決にする
        taskData.changeAchievement()
        
        // 通知
        SVProgressHUD.showSuccess(withStatus: "未解決にしました")
    }
    
    
    
    //MARK:- テーブルビューの設定
    
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
        
        // 有効性コメントを取得
        if taskData.getMeasuresEffectiveness(taskData.getMeasuresTitle(indexPath.row)).count == 0 {
            cell.detailTextLabel?.text = "有効性："
        } else {
            let obj = taskData.getMeasuresEffectiveness(taskData.getMeasuresTitle(indexPath.row))
            
            // obj.keysのまま表示すると [""]が表示されるため、キーだけの配列を作成
            let stringArray = Array(obj[0].keys)
            cell.detailTextLabel?.text = "有効性：\(stringArray[0])"
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
            taskData.updateTaskData()
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // セルの内容を表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        taskTitleTextField.text = taskData.getTaskTitle()
        taskCauseTextView.text  = taskData.getTaskCouse()
    }

}
