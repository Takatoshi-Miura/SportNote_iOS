//
//  ResolvedMeasuresDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/02.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class ResolvedMeasuresDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの指定
        tableView.delegate   = self
        tableView.dataSource = self
        
        // チェックボックスの設定
        self.checkButton.setImage(uncheckedImage, for: .normal)
        self.checkButton.setImage(checkedImage, for: .selected)

        // データのないセルを非表示
        tableView.tableFooterView = UIView()
        
        // 受け取った対策データを表示
        printMeasuresData(taskData)
    }
    
    
    
    //MARK:- 変数の宣言
    var taskData = TaskData()   // 課題データ格納用
    var indexPath = 0           // 行番号格納用
    
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var measuresTitleTextField: UITextField!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    
    // チェックボックス
    @IBOutlet weak var checkButton: UIButton!
    private let checkedImage = UIImage(named: "check_on")
    private let uncheckedImage = UIImage(named: "check_off")
    
    // チェックボックスがタップされた時の処理
    @IBAction func checkButtonTap(_ sender: Any) {
        // 編集不可
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 有効性コメント数を返却
        return self.taskData.getMeasuresEffectiveness(self.taskData.getMeasuresTitle(indexPath)).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        //cell.textLabel!.text = self.taskData.getMeasuresEffectiveness(self.taskData.getMeasuresTitle(self.indexPath))[indexPath.row]
        return cell
    }
    
    
    
    //MARK:- その他のメソッド
    
    // データを表示するメソッド
    func printMeasuresData(_ taskData:TaskData) {
        // テキストの表示
        measuresTitleTextField.text = taskData.getMeasuresTitle(indexPath)
        
        // 最有力の対策ならチェックボックスを選択済みにする
        if taskData.getMeasuresPriorityIndex() == indexPath {
            self.checkButton.isSelected = !self.checkButton.isSelected
        }
    }
    
    


}
