//
//  MeasuresDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/29.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class MeasuresDetailViewController: UIViewController,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの指定
        navigationController?.delegate = self

        // 受け取った対策データを表示
        printMeasuresData(taskData)
    }
    
    // テキスト
    @IBOutlet weak var measuresTitleTextField: UITextField!
    @IBOutlet weak var measuresEffectivenessTextView: UITextView!
    
    // 課題データ格納用
    var taskData = TaskData()
    var indexPath = 0
    
    
    // データを表示するメソッド
    func printMeasuresData(_ taskData:TaskData) {
        measuresTitleTextField.text        = taskData.getMeasuresTitle(indexPath)
        measuresEffectivenessTextView.text = taskData.getMeasuresEffectiveness(indexPath)
    }
    
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is TaskDetailViewController {
            // 対策データを更新
            taskData.updateMeasures(measuresTitleTextField.text!, measuresEffectivenessTextView.text!, indexPath)
            taskData.updateTaskData()
        }
    }
    

}
