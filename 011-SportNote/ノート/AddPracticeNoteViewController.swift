//
//  AddPracticeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/06.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddPracticeNoteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        typePicker.delegate      = self
        typePicker.dataSource    = self
        weatherPicker.delegate   = self
        weatherPicker.dataSource = self
        
        // Pickerのタグ付け
        typePicker.tag    = 0
        weatherPicker.tag = 1
    }
    
    
    
    //MARK:- 変数の宣言
    
    // Picker用ビュー
    var pickerView = UIView()
    
    // 種別Picker
    let typePicker = UIPickerView()
    let noteType:[String] = ["----","目標設定","練習記録","大会記録"]
    var typeIndex:Int = 2
    
    // 日付Picker
    var datePicker = UIDatePicker()
    
    // 天候Picker
    let weatherPicker = UIPickerView()
    let weather:[String]  = ["晴れ","くもり","雨"]
    let temperature:[Int] = (-40...40).map { $0 }
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3    // 種別セル,日付セル,天候セルの3つ
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if indexPath.row == 0 {
            // 0行目のセルは種別セルを返却
            cell.textLabel!.text = "種別"
            cell.detailTextLabel!.text = noteType[typeIndex]
            cell.detailTextLabel?.textColor = UIColor.systemGray
            return cell
        } else if indexPath.row == 1 {
            // 1行目のセルは日付セルを返却
            cell.textLabel!.text = "日付"
            cell.detailTextLabel!.text = getCurrentTime()
            cell.detailTextLabel?.textColor = UIColor.systemGray
            return cell
        } else {
            // 2行目のセルは天候セルを返却
            cell.textLabel!.text = "天候"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // 種別セルがタップされた時
            // Pickerの初期化
            typeCellPickerInit()
            
            // 下からPickerを呼び出す
            let screenSize = UIScreen.main.bounds.size
            pickerView.frame.origin.y = screenSize.height
            UIView.animate(withDuration: 0.3) {
                self.pickerView.frame.origin.y = screenSize.height - self.pickerView.bounds.size.height
            }
        } else if indexPath.row == 1 {
            // 日付セルがタップされた時
            // Pickerの初期化
            datePickerInit()
            
            // 下からPickerを呼び出す
            let screenSize = UIScreen.main.bounds.size
            pickerView.frame.origin.y = screenSize.height
            UIView.animate(withDuration: 0.3) {
                self.pickerView.frame.origin.y = screenSize.height - self.pickerView.bounds.size.height
            }
        } else {
            // 天候セルがタップされた時
            // Pickerの初期化
            weatherPickerInit()
            
            // 下からPickerを呼び出す
            let screenSize = UIScreen.main.bounds.size
            pickerView.frame.origin.y = screenSize.height
            UIView.animate(withDuration: 0.3) {
                self.pickerView.frame.origin.y = screenSize.height - self.pickerView.bounds.size.height
            }
        }
    }
    
    
    
    //MARK:- Pickerの設定
    
    // Pickerの列数を返却
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 1    // 種別Pickerは1つ
        } else {
            return 2    // 天候Pickerは天気,気温の2つ
        }
    }
    
    // Pickerの項目を返却
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return noteType.count           // 種別Pickerの項目数
        } else if pickerView.tag == 1 {
            if component == 0 {
                return weather.count        // 天候Pickerの天気の項目数
            } else if component == 1 {
                return temperature.count    // 天候Pickerの気温の項目数
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    // Pickerの文字を返却
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return noteType[row]                // 種別Pickerの項目
        } else if pickerView.tag == 1 {
            if component == 0 {
                return "\(weather[row])"        // 天候Pickerの天気
            } else if component == 1 {
                return "\(temperature[row])℃"    // 天候Pickerの気温
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // 選択された年月を取得
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            typeIndex = row
        }
        if pickerView.tag == 1 {
            // 天候Pickerの選択を取得
        }
    }
    
    // 種別セル初期化メソッド
    func typeCellPickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // Pickerの宣言
        typePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: typePicker.bounds.size.height)
        
        // ツールバーの宣言
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.typeDone))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.typeCancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        
        // ビューを追加
        pickerView = UIView(frame: typePicker.bounds)
        pickerView.addSubview(typePicker)
        pickerView.addSubview(toolbar)
        view.addSubview(pickerView)
    }
    
    // キャンセルボタンの処理
    @objc func typeCancel() {
        // Pickerをしまう
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = UIScreen.main.bounds.size.height + self.pickerView.bounds.size.height
        }
        
        // テーブルビューを更新
        tableView.reloadData()
    }
    
    // 完了ボタンの処理
    @objc func typeDone() {
        // Pickerをしまう
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = UIScreen.main.bounds.size.height + self.pickerView.bounds.size.height
        }
           
        // テーブルビューを更新
        tableView.reloadData()
           
        // 画面遷移
        switch typeIndex {
        case 0:
            // AddNoteViewControllerに遷移する意味はないため、現在の画面に留まる
            break
        case 1:
            // 目標追加画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "AddTargetViewController")
            self.present(nextView, animated: false, completion: nil)
            break
        case 2:
            // 練習記録追加画面に遷移
            break
        case 3:
            // 大会記録追加画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "AddTargetViewController")
            self.present(nextView, animated: false, completion: nil)
            break
        default:
            break
        }
    }
    
    // 日付Pickerの初期化メソッド
    func datePickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // 設定
        datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
        
        // ツールバーの宣言
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.typeDone))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.typeCancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        
        // ビューを追加
        pickerView = UIView(frame: datePicker.bounds)
        pickerView.addSubview(datePicker)
        pickerView.addSubview(toolbar)
        view.addSubview(pickerView)
    }
    
    // 天候Pickerの初期化メソッド
    func weatherPickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // Pickerの宣言
        weatherPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: weatherPicker.bounds.size.height)
        
        // ツールバーの宣言
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.typeDone))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.typeCancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        
        // ビューを追加
        pickerView = UIView(frame: weatherPicker.bounds)
        pickerView.addSubview(weatherPicker)
        pickerView.addSubview(toolbar)
        view.addSubview(pickerView)
    }
    
    
    
    //MARK:- その他のメソッド
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "y年M月d日(E)"
        return dateFormatter.string(from: now)
    }
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
