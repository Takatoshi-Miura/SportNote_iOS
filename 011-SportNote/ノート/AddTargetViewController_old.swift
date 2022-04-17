//
//  AddTargetViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/04.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddTargetViewController_old: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートとデータソースの指定
        tableView.delegate       = self
        tableView.dataSource     = self
        typePicker.delegate      = self
        typePicker.dataSource    = self
        periodPicker.delegate    = self
        periodPicker.dataSource  = self
        targetTextField.delegate = self
        
        // Pickerのタグ付け
        typePicker.tag   = 0
        periodPicker.tag = 1
        
        // 初期値の設定(2020年に設定)
        periodPicker.selectRow(71, inComponent: 0, animated: true)

        // データのないセルを非表示
        self.tableView.tableFooterView = UIView()
        
        // データ取得
        loadTargetData()
        
        // ツールバーを作成
        targetTextField.inputAccessoryView = createToolBar(#selector(tapOkButton(_:)), #selector(tapOkButton(_:)))
    }
    
    
    
    //MARK:- 変数の宣言
    
    // Picker用ビュー
    var pickerView = UIView()
    
    // 種別Picker
    let typePicker = UIPickerView()
    let noteType:[String] = ["----","目標設定","練習記録","大会記録"]
    var typeIndex:Int = 1
    
    // 期間Picker
    let periodPicker = UIPickerView()
    let years  = (1950...2200).map { $0 }
    let months = ["--","1","2","3","4","5","6","7","8","9","10","11","12"]
    var selectedYear:Int  = 2021
    var selectedMonth:Int = 13   // "--"が選択された時は13が入る
    
    // データ格納用
    var dataManager = DataManager()
    
    // 終了フラグ
    var saveFinished:Bool = false
    
    // キーボードでテキストフィールドが隠れないための設定用
    var selectedTextField: UITextField?
    var selectedTextView: UITextView?
    let screenSize = UIScreen.main.bounds.size
    var textHeight:CGFloat = 0.0
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // テキストフィールド
    @IBOutlet weak var targetTextField: UITextField!
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
        // その月の年間目標データがなければ作成
        if self.dataManager.targetDataArray.count == 0 {
            if selectedMonth == 13 {
                // 年間目標データを保存
                self.saveFinished = true
                saveTargetData(selectedYear,selectedMonth,comment: targetTextField.text!)
            } else {
                // 月間目標データを保存したなら年間目標データも作成
                saveTargetData(selectedYear,selectedMonth,comment: targetTextField.text!)
                self.saveFinished = true
                saveTargetData(selectedYear,13,comment: "")
            }
        } else {
            // 既に目標登録済みの月を取得(同じ年の)
            var monthArray:[Int] = []
            for num in 0...(self.dataManager.targetDataArray.count - 1) {
                if self.dataManager.targetDataArray[num].getYear() == selectedYear {
                    monthArray.append(self.dataManager.targetDataArray[num].getMonth())
                }
            }
            // 年間目標の登録がなければ、年間目標作成
            if monthArray.firstIndex(of: 13) == nil && selectedMonth == 13 {
                self.saveFinished = true
                saveTargetData(selectedYear,selectedMonth,comment: targetTextField.text!)
            } else if monthArray.firstIndex(of: 13) == nil {
                saveTargetData(selectedYear,13, comment: "")
                self.saveFinished = true
                saveTargetData(selectedYear,selectedMonth,comment: targetTextField.text!)
            } else {
                self.saveFinished = true
                saveTargetData(selectedYear,selectedMonth,comment: targetTextField.text!)
            }
        }
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2   // 種別セル,期間セルの2つ
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // 0行目のセルは種別セルを返却
            let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
            cell.textLabel!.text = "種別"
            cell.detailTextLabel!.text = noteType[typeIndex]
            cell.detailTextLabel?.textColor = UIColor.systemGray
            return cell
        } else {
            // 1行目のセルは期間セルを返却
            let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
            cell.textLabel!.text = "期間"
            if selectedMonth == 13 {
                cell.detailTextLabel!.text = "\(selectedYear)年 年間目標"
            } else {
                cell.detailTextLabel!.text = "\(selectedYear)年 \(selectedMonth)月 月間目標"
            }
            cell.detailTextLabel?.textColor = UIColor.systemGray
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // 種別セルがタップされた時
            typeCellPickerInit()
        } else {
            // 期間セルがタップされた時
            periodCellPickerInit()
        }
        // 下からPickerを呼び出す
        openPicker(pickerView)
    }
    
    
    
    //MARK:- Pickerの設定
    
    // 種別セル初期化メソッド
    func typeCellPickerInit() {
        // Pickerの宣言
        typePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: typePicker.bounds.size.height)
        typePicker.backgroundColor = UIColor.systemGray5
        
        // ビューを追加
        pickerView = UIView(frame: typePicker.bounds)
        pickerView.addSubview(typePicker)
        pickerView.addSubview(createToolBar(#selector(typeDone), #selector(cancelAction)))
        view.addSubview(pickerView)
    }
    
    // 期間セル初期化メソッド
    func periodCellPickerInit() {
        // Pickerの宣言
        periodPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: periodPicker.bounds.size.height)
        periodPicker.backgroundColor = UIColor.systemGray5
        
        // ビューを追加
        pickerView = UIView(frame: periodPicker.bounds)
        pickerView.addSubview(periodPicker)
        pickerView.addSubview(createToolBar(#selector(periodDone), #selector(cancelAction)))
        view.addSubview(pickerView)
    }
    
    // キャンセルボタンの処理
    @objc func cancelAction() {
        // Pickerをしまう
        closePicker(pickerView)
        
        // テーブルビューを更新
        tableView.reloadData()
    }
    
    // 完了ボタンの処理
    @objc func typeDone() {
        // 選択されたIndexを取得
        typeIndex = typePicker.selectedRow(inComponent: 0)
        
        // Pickerをしまう
        closePicker(pickerView)
           
        // テーブルビューを更新
        tableView.reloadData()
           
        // 画面遷移
        switch typeIndex {
        case 0:
            // AddNoteViewControllerに遷移する意味はないため、現在の画面に留まる
            break
        case 1:
            // 目標追加画面のまま
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
    
    // 完了ボタンの処理
    @objc func periodDone() {
        // 選択された項目を取得
        selectedYear  = years[periodPicker.selectedRow(inComponent: 0)]
        selectedMonth = periodPicker.selectedRow(inComponent: 1)
        if selectedMonth == 0 {
            selectedMonth = 13  // HACK:年間目標は最上位に表示させるため、12月よりも大きい13をセットする
        }
        
        // Pickerをしまう
        closePicker(pickerView)
        
        // テーブルビューを更新
        tableView.reloadData()
    }
    
    
    // Pickerの列数を返却
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 1   // 種別Pickerは1つ
        } else {
            return 2   // 期間Pickerは年,月の２つ
        }
    }
    
    // Pickerの項目を返却
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return noteType.count           // 種別Pickerの項目数
        } else {
            if component == 0 {
                return years.count          // 期間Pickerの年の項目数
            } else if component == 1 {
                return months.count         // 期間Pickerの月の項目数
            } else {
                return 0
            }
        }
    }
    
    // Pickerの文字を返却
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return noteType[row]                // 種別Pickerの項目
        } else {
            if component == 0 {
                return "\(years[row])年"        // 期間Pickerの年数
            } else if component == 1 {
                if months[row] == "--" {
                    return "年間目標"
                } else {
                    return "\(months[row])月"   // 期間Pickerの月数
                }
            } else {
                return nil
            }
        }
    }
    
    
    //MARK:- データベース関連
    
    // 目標データを取得
    func loadTargetData() {
        dataManager.getTargetData({})
    }
    
    // 目標データを保存（新規目標追加時のみ使用）
    func saveTargetData(_ selectedYear:Int, _ selectedMonth:Int, comment detail:String) {
        dataManager.saveTargetData(selectedYear, selectedMonth, detail, {
            // 最後のデータ保存であればノート画面に遷移
            if self.saveFinished == true {
                // ストーリーボードを取得
                let storyboard: UIStoryboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                // ノート画面に遷移
                self.present(nextView, animated: false, completion: nil)
            }
        })
    }
    
    
    //MARK:- その他のメソッド
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
}
