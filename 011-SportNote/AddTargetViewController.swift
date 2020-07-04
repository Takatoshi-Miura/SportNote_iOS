//
//  AddTargetViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/04.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddTargetViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Pickerの初期化
        pickerInit()
    }
    
    
    
    //MARK:- 変数の宣言
    
    let years  = (1950...2200).map { $0 }
    let months = ["--","1","2","3","4","5","6","7","8","9","10","11","12"]
    
    
    
    //MARK:- UIの設定
    
    // Picker
    @IBOutlet weak var pickerView: UIPickerView!
    
    // テキスト
    @IBOutlet weak var targetTextField: UITextField!
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
    }
    
    
    
    //MARK:- Pickerの設定
    
    // 初期化メソッド
    func pickerInit() {
        // デリゲートの指定
        pickerView.delegate = self
        
        // 初期値の設定(2020年に設定)
        pickerView.selectRow(70, inComponent: 0, animated: true)
    }
    
    // Pickerの列数を返却
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2   // 年,月の２つ
    }
    
    // Pickerの項目を返却
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else if component == 1 {
            return months.count
        } else {
            return 0
        }
    }
    
    // Pickerの添え字を返却
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])年"
        } else if component == 1 {
            return "\(months[row])月"
        } else {
            return nil
        }
    }
    
    // 選択された年月を取得
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year = years[pickerView.selectedRow(inComponent: 0)]
        let month = months[pickerView.selectedRow(inComponent: 1)]
        let text = "\(year)年 \(month)月"
    }
    
    
}
