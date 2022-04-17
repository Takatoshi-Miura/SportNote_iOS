//
//  AddNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートとデータソースの指定
        tableView.delegate   = self
        tableView.dataSource = self
        
        // データのないセルを非表示
        self.tableView.tableFooterView = UIView()
    }
    
    
    
    //MARK:- 変数の宣言

    // Picker用
    let picker = UIPickerView()
    let noteType:[String] = ["----","目標設定","練習記録","大会記録"]
    var index:Int = 0
    var pickerView = UIView()
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 戻るボタンの処理
    @IBAction func backButton(_ sender: Any) {
        // NoteViewControllerへ遷移
    }
    

    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1   // 種別のみのため1を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        cell.textLabel!.text = "種別"
        cell.detailTextLabel!.text = noteType[index]
        cell.detailTextLabel?.textColor = UIColor.systemGray
        return cell
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Pickerの宣言
        picker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: picker.bounds.size.height)
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.systemGray5
        
        // ビューを追加
        pickerView = UIView(frame: picker.bounds)
        pickerView.addSubview(picker)
        pickerView.addSubview(createToolBar(#selector(done), #selector(cancel)))
        view.addSubview(pickerView)
        
        // 下からPickerを呼び出す
        openPicker(pickerView)
    }
    
    
    
    //MARK:- Pickerの設定
    
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
        index = row
    }
    
    @objc func cancel() {
        // Pickerをしまう
        closePicker(pickerView)
        
        // Pickerにデフォルト値をセット
        index = 0
        
        // テーブルビューを更新
        tableView.reloadData()
    }

    @objc func done() {
        // 選択されたIndexを取得
        index = picker.selectedRow(inComponent: 0)
        
        // Pickerをしまう
        closePicker(pickerView)
        
        // テーブルビューを更新
        tableView.reloadData()
        
        // 画面遷移
        switch index {
        case 0:
            break
        case 1:
            // 目標追加画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "AddTargetViewController_old")
            self.present(nextView, animated: false, completion: nil)
            break
        case 2:
            // 練習記録追加画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "AddPracticeNoteViewController")
            self.present(nextView, animated: false, completion: nil)
            break
        case 3:
            // 大会記録追加画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "AddCompetitionNoteViewController")
            self.present(nextView, animated: false, completion: nil)
            break
        default:
            break
        }
    }

}
