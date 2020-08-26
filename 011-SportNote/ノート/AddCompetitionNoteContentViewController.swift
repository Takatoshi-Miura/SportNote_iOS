//
//  AddCompetitionNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/07.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddCompetitionNoteContentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource,UITextViewDelegate {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        typePicker.delegate      = self
        typePicker.dataSource    = self
        weatherPicker.delegate   = self
        weatherPicker.dataSource = self
        physicalConditionTextView.delegate = self
        targetTextView.delegate = self
        consciousnessTextView.delegate = self
        resultTextView.delegate = self
        reflectionTextView.delegate = self
        
        // Pickerのタグ付け
        typePicker.tag    = 0
        weatherPicker.tag = 1
        
        // 初期値の設定(気温20度に設定)
        weatherPicker.selectRow(60, inComponent: 1, animated: true)
        selectedDate = getCurrentPickerTime()
        
        // テキストビューに枠線追加
        addTextViewBorder()
        
        // キーボードでテキストフィールドが隠れない設定
        configureObserver()
        
        // ツールバーを作成
        createToolBar()
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // データ取得
        loadTargetData()
        
        // CompetitionNoteDetailViewControllerから遷移してきた場合
        if previousControllerName == "CompetitionNoteDetailViewController" {
            // 受け取ったノートデータを反映
            
            // 初期値の設定(受け取ったnoteDataに値に設定)
            setWeatherPicker(noteData: self.competitionNoteData)
            
            // テキストビューに値をセット
            setTextData(noteData: self.competitionNoteData)
            
            // 日付Pickerに値をセット
            setDatePicker(noteData: self.competitionNoteData)
            
            // テーブルビューの高さ調整
            self.tableViewHeight.constant = 100
            
            // テーブルビューを更新
            self.tableView.reloadData()
            
        } else {
            // 設定に時間がかかるため、ここでノートIDの設定もしておく。保存時にやるとID設定前にノートが保存されてしまう。
            competitionNoteData.setNewNoteID()
        }
    }
    
    
    
    //MARK:- 変数の宣言
    
    // Picker用ビュー
    var pickerView = UIView()
    var bottomPadding:CGFloat = 0
    let toolbarHeight:CGFloat = 44
    
    // 種別Picker
    let typePicker = UIPickerView()
    let noteType:[String] = ["----","目標設定","練習記録","大会記録"]
    var typeIndex:Int = 3
    
    // 日付Picker
    var datePicker = UIDatePicker()
    var selectedDate:String = ""
    var year:Int = 2020
    var month:Int = 1
    var date:Int = 1
    var day:String = ""
    
    // 天候Picker
    let weatherPicker = UIPickerView()
    let weather:[String]  = ["晴れ","くもり","雨"]
    let temperature:[Int] = (-40...40).map { $0 }
    var weatherIndex:Int = 0
    var temperatureIndex:Int = 60
    
    // データ格納用
    var targetDataArray = [TargetData]()
    var competitionNoteData = NoteData()
    
    // データ保存終了フラグ
    var saveDataFinished:Bool = false
    
    // ノート詳細確認画面からの遷移用
    var previousControllerName:String = ""  // 前のViewController名
    
    // キーボードでテキストフィールドが隠れないための設定用
    var selectedTextView: UITextView?
    let screenSize = UIScreen.main.bounds.size
    var textHeight:CGFloat = 0.0
    var navBarHeight:CGFloat = 44.0
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // テキストビュー
    @IBOutlet weak var physicalConditionTextView: UITextView!
    @IBOutlet weak var targetTextView: UITextView!
    @IBOutlet weak var consciousnessTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    
    // 保存ボタンの処理
    func saveButton() {
        // 大会ノートデータをFirebaseに保存
        saveNoteData()
        
        // 目標データがなければ作成
        if targetDataArray.isEmpty == true {
            // 月間目標データを作成
            saveTargetData(year: self.year, month: self.month)
            
            // フラグ
            saveDataFinished = true
            
            // 年間目標データを作成
            saveTargetData(year: self.year, month: 13)
        } else {
            // 既に目標登録済みの月を取得(同じ年の)
            var monthArray:[Int] = []
            for num in 0...(targetDataArray.count - 1) {
                if targetDataArray[num].getYear() == self.year {
                    monthArray.append(targetDataArray[num].getMonth())
                }
            }
            
            // 月間,年間双方の登録がなければ、目標作成
            if monthArray.firstIndex(of: self.month) == nil && monthArray.firstIndex(of: 13) == nil {
                // 月間目標データを作成
                saveTargetData(year: self.year, month: self.month)
                
                // フラグ
                saveDataFinished = true
                
                // 年間目標データを作成
                saveTargetData(year: self.year, month: 13)
            } else if monthArray.firstIndex(of: self.month) == nil {
                // 年間目標のみ存在する場合
                // フラグ
                saveDataFinished = true
                
                // 月間目標データを作成
                saveTargetData(year: self.year, month: self.month)
            } else if monthArray.firstIndex(of: 13) == nil {
                // 月間目標のみ存在する場合
                // フラグ
                saveDataFinished = true
                
                // 年間目標データを作成
                saveTargetData(year: self.year, month: 13)
            } else {
                // 月間,年間ともに存在する場合
                // ストーリーボードを取得
                let storyboard: UIStoryboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                
                // デフォルトでは下から上のアニメーションとなるため、それを上から下に変更
                let transition = CATransition()
                transition.duration = 0.15
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromBottom
                view.window!.layer.add(transition, forKey: kCATransition)
                
                // ノート画面に遷移
                self.present(nextView, animated: false, completion: nil)
            }
        }
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // CompetitionNoteDetailViewControllerから遷移してきた場合
        if previousControllerName == "CompetitionNoteDetailViewController" {
            return 2    // 日付セル,天候セルの2つ
        } else {
            return 3    // 種別セル,日付セル,天候セルの3つ
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // 0行目のセル
        if indexPath.row == 0 {
            // CompetitionNoteDetailViewControllerから遷移してきた場合
            if previousControllerName == "CompetitionNoteDetailViewController" {
                // 日付セルを返却
                cell.textLabel!.text = "日付"
                cell.detailTextLabel!.text = selectedDate
                cell.detailTextLabel?.textColor = UIColor.systemGray
                return cell
            } else {
                // 種別セルを返却
                cell.textLabel!.text = "種別"
                cell.detailTextLabel!.text = noteType[typeIndex]
                cell.detailTextLabel?.textColor = UIColor.systemGray
                return cell
            }
        // 1行目のセル
        } else if indexPath.row == 1 {
            // CompetitionNoteDetailViewControllerから遷移してきた場合
            if previousControllerName == "CompetitionNoteDetailViewController" {
                // 天候セルを返却
                cell.textLabel!.text = "天候"
                cell.detailTextLabel!.text = "\(weather[weatherIndex]) \(temperature[temperatureIndex])℃"
                cell.detailTextLabel?.textColor = UIColor.systemGray
                return cell
            } else {
                // 日付セルを返却
                cell.textLabel!.text = "日付"
                cell.detailTextLabel!.text = selectedDate
                cell.detailTextLabel?.textColor = UIColor.systemGray
                return cell
            }
        // 2行目のセル
        } else {
            // 天候セルを返却
            cell.textLabel!.text = "天候"
            cell.detailTextLabel!.text = "\(weather[weatherIndex]) \(temperature[temperatureIndex])℃"
            cell.detailTextLabel?.textColor = UIColor.systemGray
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 0行目のセルがタップされた時
        if indexPath.row == 0 {
            // CompetitionNoteDetailViewControllerから遷移してきた場合
            if previousControllerName == "CompetitionNoteDetailViewController" {
                // タップしたときの選択色を消去
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                
                // 日付Pickerの初期化
                datePickerInit()
                
                // 下からPickerを出す
                openPicker(pickerView: pickerView)
            } else {
                // タップしたときの選択色を消去
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                
                // 種別Pickerの初期化
                typeCellPickerInit()
                
                // 下からPickerを出す
                openPicker(pickerView: pickerView)
            }
        // 1行目のセルがタップされた時
        } else if indexPath.row == 1 {
            // CompetitionNoteDetailViewControllerから遷移してきた場合
            if previousControllerName == "CompetitionNoteDetailViewController" {
                // タップしたときの選択色を消去
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                
                // 天候Pickerの初期化
                weatherPickerInit()
                
                // 下からPickerを出す
                openPicker(pickerView: pickerView)
            } else {
                // タップしたときの選択色を消去
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                
                // 日付Pickerの初期化
                datePickerInit()
                
                // 下からPickerを出す
                openPicker(pickerView: pickerView)
            }
        // 2行目のセルがタップされた時
        } else {
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            // 天候Pickerの初期化
            weatherPickerInit()
            
            // 下からPickerを出す
            openPicker(pickerView: pickerView)
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
    
    // 種別セル初期化メソッド
    func typeCellPickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // 種別Pickerの宣言
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
    
    // キャンセルボタンの処理
    @objc func typeCancel() {
        // Pickerをしまう
        closePicker()
        
        // テーブルビューを更新
        tableView.reloadData()
    }
    
    // 完了ボタンの処理
    @objc func typeDone() {
        // 選択されたIndexを取得
        typeIndex = typePicker.selectedRow(inComponent: 0)
        
        // Pickerをしまう
        closePicker()
           
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
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "AddPracticeNoteViewController")
            self.present(nextView, animated: false, completion: nil)
            break
        case 3:
            // 大会記録追加画面のまま
            break
        default:
            break
        }
    }
    
    // 日付Pickerの初期化メソッド
    func datePickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // 日付Pickerの宣言
        datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
        datePicker.backgroundColor = UIColor.systemGray5
        datePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height)
        
        // ツールバーの宣言
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.datePickerDone))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.typeCancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        
        // ビューを追加
        pickerView = UIView(frame: datePicker.bounds)
        pickerView.addSubview(datePicker)
        pickerView.addSubview(toolbar)
        view.addSubview(pickerView)
    }
    
    // 完了ボタンの処理
    @objc func datePickerDone() {
        // 選択された日付を取得
        selectedDate = getDatePickerDate()
        
        // Pickerをしまう
        closePicker()
           
        // テーブルビューを更新
        tableView.reloadData()
    }
    
    // 天候Pickerの初期化メソッド
    func weatherPickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // 天候Pickerの宣言
        weatherPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: weatherPicker.bounds.size.height)
        weatherPicker.backgroundColor = UIColor.systemGray5
        
        // ツールバーの宣言
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.weatherDone))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.typeCancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        
        // ビューを追加
        pickerView = UIView(frame: weatherPicker.bounds)
        pickerView.addSubview(weatherPicker)
        pickerView.addSubview(toolbar)
        view.addSubview(pickerView)
    }
    
    // 完了ボタンの処理
    @objc func weatherDone() {
        // 選択されたIndexを取得
        weatherIndex     = weatherPicker.selectedRow(inComponent: 0)
        temperatureIndex = weatherPicker.selectedRow(inComponent: 1)
        
        // Pickerをしまう
        closePicker()
           
        // テーブルビューを更新
        tableView.reloadData()
    }
    
    // Pickerを画面下から開くメソッド
    func openPicker(pickerView picker:UIView) {
        // 現在のスクロール位置（最下点）,Pickerの座標を取得
        let obj = self.parent as! AddCompetitionNoteViewController
        let scrollPotiton = obj.getScrollPosition()
        picker.frame.origin.y = scrollPotiton
        
        // 下からPickerを出す
        UIView.animate(withDuration: 0.3) {
            picker.frame.origin.y = scrollPotiton - picker.bounds.size.height - self.toolbarHeight - self.bottomPadding
        }
    }
    
    // Pickerをしまうメソッド
    func closePicker() {
        // 現在のスクロール位置（最下点）,Pickerの座標を取得
        let obj = self.parent as! AddCompetitionNoteViewController
        let scrollPotiton = obj.getScrollPosition()
        
        // Pickerをしまう
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = scrollPotiton + self.pickerView.bounds.size.height
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            // ビューの初期化
            self.pickerView.removeFromSuperview()
        }
    }
    
    
    
    //MARK:- データベース関連
    
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
    
    // Firebaseにノートデータを保存するメソッド
    func saveNoteData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 大会ノートデータを作成
        competitionNoteData.setNoteType("大会記録")
        
        // Pickerの選択項目をセット
        competitionNoteData.setYear(year)
        competitionNoteData.setMonth(month)
        competitionNoteData.setDate(date)
        competitionNoteData.setDay(day)
        competitionNoteData.setWeather(weather[weatherIndex])
        competitionNoteData.setTemperature(temperature[temperatureIndex])
        
        // 入力テキストをセット
        competitionNoteData.setPhysicalCondition(physicalConditionTextView.text!)
        competitionNoteData.setTarget(targetTextView.text!)
        competitionNoteData.setConsciousness(consciousnessTextView.text!)
        competitionNoteData.setResult(resultTextView.text!)
        competitionNoteData.setReflection(reflectionTextView.text!)
        
        // ユーザーUIDをセット
        competitionNoteData.setUserID(userID)
        
        // 現在時刻をセット
        competitionNoteData.setCreated_at(getCurrentTime())
        competitionNoteData.setUpdated_at(competitionNoteData.getCreated_at())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("NoteData").document("\(competitionNoteData.getUserID())_\(competitionNoteData.getNoteID())").setData([
            "noteID"                : competitionNoteData.getNoteID(),
            "noteType"              : competitionNoteData.getNoteType(),
            "year"                  : competitionNoteData.getYear(),
            "month"                 : competitionNoteData.getMonth(),
            "date"                  : competitionNoteData.getDate(),
            "day"                   : competitionNoteData.getDay(),
            "weather"               : competitionNoteData.getWeather(),
            "temperature"           : competitionNoteData.getTemperature(),
            "physicalCondition"     : competitionNoteData.getPhysicalCondition(),
            "purpose"               : competitionNoteData.getPurpose(),
            "detail"                : competitionNoteData.getDetail(),
            "target"                : competitionNoteData.getTarget(),
            "consciousness"         : competitionNoteData.getConsciousness(),
            "result"                : competitionNoteData.getResult(),
            "reflection"            : competitionNoteData.getReflection(),
            "taskTitle"             : competitionNoteData.getTaskTitle(),
            "measuresTitle"         : competitionNoteData.getMeasuresTitle(),
            "measuresEffectiveness" : competitionNoteData.getMeasuresEffectiveness(),
            "isDeleted"             : competitionNoteData.getIsDeleted(),
            "userID"                : competitionNoteData.getUserID(),
            "created_at"            : competitionNoteData.getCreated_at(),
            "updated_at"            : competitionNoteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                
                // CompetitionNoteDetailViewControllerから遷移してきた場合
                if self.previousControllerName == "CompetitionNoteDetailViewController" {
                    // ストーリーボードを取得
                    let storyboard: UIStoryboard = self.storyboard!
                    let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                    
                    // ノート画面に遷移
                    self.present(nextView, animated: false, completion: nil)
                }
            }
        }
    }
    
    // Firebaseに目標データを保存するメソッド（新規目標追加時のみ使用）
    func saveTargetData(year selectedYear:Int,month selectedMonth:Int) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 目標データを作成
        let targetData = TargetData()
        
        // 年月をセット
        targetData.setYear(selectedYear)
        targetData.setMonth(selectedMonth)
        
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
                
                // 最後の保存であればモーダルを閉じる
                if self.saveDataFinished == true {
                    // ストーリーボードを取得
                    let storyboard: UIStoryboard = self.storyboard!
                    let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                    
                    // ノート画面に遷移
                    self.present(nextView, animated: false, completion: nil)
                }
            }
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // ノートデータのテキストをセットするメソッド
    func setTextData(noteData note:NoteData) {
        self.physicalConditionTextView.text = note.getPhysicalCondition()
        self.targetTextView.text = note.getTarget()
        self.consciousnessTextView.text = note.getConsciousness()
        self.resultTextView.text = note.getResult()
        self.reflectionTextView.text = note.getReflection()
    }
    
    // ノートの日付をDatePickerにセットするメソッド
    func setDatePicker(noteData note:NoteData) {
        // 日付をセット
        self.year  = note.getYear()
        self.month = note.getMonth()
        self.date  = note.getDate()
        self.day   = note.getDay()
        
        // DatePickerに日付をセット
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd"
        let date = dateFormater.date(from: "\(self.year)/\(self.month)/\(self.date)")
        datePicker.date = date!
        
        self.selectedDate = "\(self.year)年\(self.month)月\(self.date)日(\(self.day))"
    }
    
    // 天候データをweatherPickerにセットするメソッド
    func setWeatherPicker(noteData note:NoteData) {
        // 気温をセット
        self.temperatureIndex = note.getTemperature() + 40
        self.weatherPicker.selectRow(self.temperatureIndex, inComponent: 1, animated: true)
        
        // 天気をセット
        if note.getWeather() == "くもり" {
            self.weatherIndex = 1
        } else if note.getWeather() == "雨" {
            self.weatherIndex = 2
        }
        self.weatherPicker.selectRow(self.weatherIndex ,inComponent: 0, animated: true)
    }
    
    // 現在時刻をPickerにセットするメソッド
    func getCurrentPickerTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "y年M月d日(E)"
        let returnText = "\(dateFormatter.string(from: now))"
        
        dateFormatter.dateFormat = "y"
        year = Int("\(dateFormatter.string(from: now))")!
        dateFormatter.dateFormat = "M"
        month = Int("\(dateFormatter.string(from: now))")!
        dateFormatter.dateFormat = "d"
        date = Int("\(dateFormatter.string(from: now))")!
        dateFormatter.dateFormat = "E"
        day = String(dateFormatter.string(from: datePicker.date))
        
        return returnText
    }
    
    // ノートの日付を取得するメソッド
    func getPickerTime(year selectedYear:Int,month selectedMonth:Int,date selectedDate:Int,day selectedDay:String) -> String {
        // 日付をセット
        year = selectedYear
        month = selectedMonth
        date = selectedDate
        day = selectedDay
        return "\(selectedYear)年\(selectedMonth)月\(selectedDate)日(\(selectedDay))"
    }
    
    // DatePickerの選択した日付を取得するメソッド
    func getDatePickerDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "y年M月d日(E)"
        let returnText = "\(dateFormatter.string(from: datePicker.date))"
        
        dateFormatter.dateFormat = "y"
        year = Int("\(dateFormatter.string(from: datePicker.date))")!
        dateFormatter.dateFormat = "M"
        month = Int("\(dateFormatter.string(from: datePicker.date))")!
        dateFormatter.dateFormat = "d"
        date = Int("\(dateFormatter.string(from: datePicker.date))")!
        dateFormatter.dateFormat = "E"
        day = String(dateFormatter.string(from: datePicker.date))
        
        return returnText
    }
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    // テキストビューに枠線を追加するメソッド
    func addTextViewBorder() {
        physicalConditionTextView.layer.borderColor = UIColor.systemGray.cgColor
        physicalConditionTextView.layer.borderWidth = 1.0
        targetTextView.layer.borderColor = UIColor.systemGray.cgColor
        targetTextView.layer.borderWidth = 1.0
        consciousnessTextView.layer.borderColor = UIColor.systemGray.cgColor
        consciousnessTextView.layer.borderWidth = 1.0
        resultTextView.layer.borderColor = UIColor.systemGray.cgColor
        resultTextView.layer.borderWidth = 1.0
        reflectionTextView.layer.borderColor = UIColor.systemGray.cgColor
        reflectionTextView.layer.borderWidth = 1.0
    }
    
    // テキストフィールド以外をタップでキーボードとPickerを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        // Pickerをしまう
        closePicker()
    }
    
    // キーボードを出したときの設定
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.selectedTextView = textView
        self.textHeight = textView.frame.maxY
    }
        
    @objc func keyboardWillShow(_ notification: Notification?) {
            
        guard let rect = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
                    
        // 現在のスクロール位置（最下点）,キーボードの高さを取得
        let obj = self.parent as! AddCompetitionNoteViewController
        let scrollPotiton = obj.getScrollPosition()
        let keyboardHeight = rect.size.height
        
        // textViewDidBeginEditingが実行されるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // スクロールする高さを計算
            let hiddenHeight = keyboardHeight + self.textHeight + self.navBarHeight + 30 - scrollPotiton
            
            // スクロール処理
            if hiddenHeight > 0 {
                UIView.animate(withDuration: duration) {
                    let transform = CGAffineTransform(translationX: 0, y: -(hiddenHeight + 20))
                    self.view.transform = transform
                }
            } else {
                UIView.animate(withDuration: duration) {
                    let transform = CGAffineTransform(translationX: 0, y: -(0))
                    self.view.transform = transform
                }
            }
        }
    }
        
    @objc func keyboardWillHide(_ notification: Notification?)  {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform.identity
        }
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
        physicalConditionTextView.inputAccessoryView = toolBar
        targetTextView.inputAccessoryView = toolBar
        consciousnessTextView.inputAccessoryView = toolBar
        resultTextView.inputAccessoryView = toolBar
        reflectionTextView.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }

}
