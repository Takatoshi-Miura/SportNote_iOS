//
//  AddNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pickerの宣言
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true

        // ツールバーの設定(ボタン追加)
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: toolbar.frame.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        toolbar.setItems([cancelItem, doneItem], animated: true)

        typeTextField.inputView = picker
        typeTextField.inputAccessoryView = toolbar
    }
    
    
    
    // テキスト
    @IBOutlet weak var typeTextField: UITextField!
    

    // Picker用
    let noteType:[String] = ["目標設定","練習記録","大会記録"]
    var index:Int = 0
    
    // Picker設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return noteType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return noteType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeTextField.text = noteType[row]
        index = row
    }
    
    @objc func cancel() {
        typeTextField.text = ""
        typeTextField.endEditing(true)
    }

    @objc func done() {
        typeTextField.text = noteType[index]
        typeTextField.endEditing(true)
    }

    
    // 戻るボタンの処理
    @IBAction func backButton(_ sender: Any) {
        // NoteViewControllerへ遷移
    }
    

}
