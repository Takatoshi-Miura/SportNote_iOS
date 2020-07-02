//
//  ResolvedMeasuresDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/02.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class ResolvedMeasuresDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // チェックボックスの設定
        self.checkButton.setImage(uncheckedImage, for: .normal)
        self.checkButton.setImage(checkedImage, for: .selected)

        // 受け取った対策データを表示
        printMeasuresData(taskData)
    }
    
    // テキスト
    @IBOutlet weak var measuresTitleTextField: UITextField!
    @IBOutlet weak var measuresEffectivenessTextView: UITextView!
    
    // チェックボックス
    @IBOutlet weak var checkButton: UIButton!
    private let checkedImage = UIImage(named: "check_on")
    private let uncheckedImage = UIImage(named: "check_off")
    
    // チェックボックスがタップされた時の処理
    @IBAction func checkButtonTap(_ sender: Any) {
        //選択状態を反転させる
        self.checkButton.isSelected = !self.checkButton.isSelected
    }
    
    
    // 課題データ格納用
    var taskData = TaskData()
    var indexPath = 0
    
    
    // データを表示するメソッド
    func printMeasuresData(_ taskData:TaskData) {
        measuresTitleTextField.text        = taskData.getMeasuresTitle(indexPath)
        measuresEffectivenessTextView.text = taskData.getMeasuresEffectiveness(indexPath)
    }
    
    


}
