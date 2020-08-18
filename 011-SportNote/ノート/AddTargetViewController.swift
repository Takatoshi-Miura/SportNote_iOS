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

class AddTargetViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate {
    
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
        periodPicker.selectRow(70, inComponent: 0, animated: true)

        // データのないセルを非表示
        self.tableView.tableFooterView = UIView()
        
        // データ取得
        loadTargetData()
        
        // ツールバーを作成
        createToolBar()
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
    var selectedYear:Int  = 2020
    var selectedMonth:Int = 13   // "--"が選択された時は13が入る
    
    // データ格納用
    var targetDataArray = [TargetData]()
    
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
        if self.targetDataArray.count == 0 {
            if selectedMonth == 13 {
                // 年間目標データを保存
                self.saveFinished = true
                saveTargetData(month: selectedMonth,comment: targetTextField.text!)
            } else {
                // 月間目標データを保存したなら年間目標データも作成
                saveTargetData(month: selectedMonth,comment: targetTextField.text!)
                self.saveFinished = true
                saveTargetData(month: 13,comment: "")
            }
        } else {
            // 既に目標登録済みの月を取得(同じ年の)
            var monthArray:[Int] = []
            for num in 0...(self.targetDataArray.count - 1) {
                if self.targetDataArray[num].getYear() == selectedYear {
                    monthArray.append(self.targetDataArray[num].getMonth())
                }
            }
            // 年間目標の登録がなければ、年間目標作成
            if monthArray.firstIndex(of: 13) == nil && selectedMonth == 13 {
                self.saveFinished = true
                saveTargetData(month: selectedMonth,comment: targetTextField.text!)
            } else if monthArray.firstIndex(of: 13) == nil {
                saveTargetData(month: 13, comment: "")
                self.saveFinished = true
                saveTargetData(month: selectedMonth,comment: targetTextField.text!)
            } else {
                self.saveFinished = true
                saveTargetData(month: selectedMonth,comment: targetTextField.text!)
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
            // Pickerの宣言
            typeCellPickerInit()
            
            // 下からPickerを呼び出す
            let screenSize = UIScreen.main.bounds.size
            pickerView.frame.origin.y = screenSize.height
            UIView.animate(withDuration: 0.3) {
                self.pickerView.frame.origin.y = screenSize.height - self.pickerView.bounds.size.height
            }
        } else {
            // 期間セルがタップされた時
            // Pickerの宣言
            periodCellPickerInit()
            
            // 下からPickerを呼び出す
            let screenSize = UIScreen.main.bounds.size
            pickerView.frame.origin.y = screenSize.height
            UIView.animate(withDuration: 0.3) {
                self.pickerView.frame.origin.y = screenSize.height - self.pickerView.bounds.size.height
            }
        }
    }
    
    
    
    //MARK:- Pickerの設定
    
    // 種別セル初期化メソッド
    func typeCellPickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // Pickerの宣言
        typePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: typePicker.bounds.size.height)
        typePicker.backgroundColor = UIColor.systemGray5
        
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
    
    // 期間セル初期化メソッド
    func periodCellPickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // Pickerの宣言
        periodPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: periodPicker.bounds.size.height)
        periodPicker.backgroundColor = UIColor.systemGray5
        
        // ツールバーの宣言
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.periodDone))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.periodCancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        
        // ビューを追加
        pickerView = UIView(frame: periodPicker.bounds)
        pickerView.addSubview(periodPicker)
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
        // 選択されたIndexを取得
        typeIndex = typePicker.selectedRow(inComponent: 0)
        
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
    
    // キャンセルボタンの処理
    @objc func periodCancel() {
        // Pickerをしまう
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = UIScreen.main.bounds.size.height + self.pickerView.bounds.size.height
        }
        
        // テーブルビューを更新
        tableView.reloadData()
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
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = UIScreen.main.bounds.size.height + self.pickerView.bounds.size.height
        }
        
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
    
    
    
    //MARK:- その他のメソッド
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // ツールバーを作成するメソッド
    func createToolBar() {
        // ツールバーのインスタンスを作成
        let toolBar = UIToolbar()

        // ツールバーに配置するアイテムのインスタンスを作成
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let okButton: UIBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapOkButton(_:)))

        // アイテムを配置
        toolBar.setItems([flexibleItem, okButton], animated: true)

        // ツールバーのサイズを指定
        toolBar.sizeToFit()
        
        // テキストフィールドにツールバーを設定
        targetTextField.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    // Firebaseから目標データを取得するメソッド
    func loadTargetData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // targetDataArrayを初期化
        targetDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String

        // 現在のユーザーの目標データを取得する
        let db = Firestore.firestore()
        db.collection("TargetData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "year", descending: true)
            .order(by: "month", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 目標オブジェクトを作成
                    let targetData = TargetData()
                    
                    // 目標データを反映
                    let targetDataCollection = document.data()
                    targetData.setYear(targetDataCollection["year"] as! Int)
                    targetData.setMonth(targetDataCollection["month"] as! Int)
                    targetData.setDetail(targetDataCollection["detail"] as! String)
                    targetData.setIsDeleted(targetDataCollection["isDeleted"] as! Bool)
                    targetData.setUserID(targetDataCollection["userID"] as! String)
                    targetData.setCreated_at(targetDataCollection["created_at"] as! String)
                    targetData.setUpdated_at(targetDataCollection["updated_at"] as! String)
                    
                    // 取得データを格納
                    self.targetDataArray.append(targetData)
                }
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // Firebaseに目標データを保存するメソッド（新規目標追加時のみ使用）
    func saveTargetData(month selectedMonth:Int,comment detail:String) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 目標データを作成
        let targetData = TargetData()
        
        // 入力値を反映
        targetData.setYear(selectedYear)
        targetData.setMonth(selectedMonth)
        targetData.setDetail(detail)
        
        // ユーザーUIDをセット
        targetData.setUserID(userID)
        
        // 現在時刻をセット
        targetData.setCreated_at(getCurrentTime())
        targetData.setUpdated_at(targetData.getCreated_at())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("TargetData").document("\(userID)_\(targetData.getYear())_\(targetData.getMonth())").setData([
            "year"       : targetData.getYear(),
            "month"      : targetData.getMonth(),
            "detail"     : targetData.getDetail(),
            "isDeleted"  : targetData.getIsDeleted(),
            "userID"     : targetData.getUserID(),
            "created_at" : targetData.getCreated_at(),
            "updated_at" : targetData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                
                // 最後のデータ保存であればノート画面に遷移
                if self.saveFinished == true {
                    // ストーリーボードを取得
                    let storyboard: UIStoryboard = self.storyboard!
                    let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                    
                    // ノート画面に遷移
                    self.present(nextView, animated: false, completion: nil)
                }
            }
        }
    }
    
}
