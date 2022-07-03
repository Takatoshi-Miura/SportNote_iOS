//
//  AddPracticeNoteViewController_old.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/06.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddPracticeNoteContentViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,UITextViewDelegate {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        typePicker.delegate      = self
        typePicker.dataSource    = self
        weatherPicker.delegate   = self
        weatherPicker.dataSource = self
        taskPicker.delegate      = self
        taskPicker.dataSource    = self
        physicalConditionTextView.delegate = self
        purposeTextView.delegate = self
        detailTextView.delegate = self
        reflectionTextView.delegate = self
        navigationController?.delegate = self
        
        // セルの登録
        self.taskTableView.register(UINib(nibName: "TaskMeasuresTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskMeasuresTableViewCell")
        
        // Pickerのタグ付け
        typePicker.tag    = 0
        weatherPicker.tag = 1
        taskPicker.tag    = 2
        
        // 初期値の設定(気温20度に設定)
        weatherPicker.selectRow(60, inComponent: 1, animated: true)
        selectedDate = getCurrentPickerTime()
        
        // テキストビューの枠線付け
        addTextViewBorder()
        
        // キーボードでテキストフィールドが隠れない設定
        configureObserver()
        
        // ツールバーを作成
        physicalConditionTextView.inputAccessoryView = createToolBar(#selector(tapOkButton(_:)), #selector(tapOkButton(_:)))
        purposeTextView.inputAccessoryView = physicalConditionTextView.inputAccessoryView
        detailTextView.inputAccessoryView = physicalConditionTextView.inputAccessoryView
        reflectionTextView.inputAccessoryView = physicalConditionTextView.inputAccessoryView
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // データ取得
        loadTargetData()
        loadTaskData()
        
        // PracticeNoteDetailViewControllerから遷移してきた場合
        if previousControllerName == "PracticeNoteDetailViewController" {
            // テキストビューに値をセット
            setTextData(noteData: self.practiceNoteData)
            
            // 日付Pickerにデータをセット
            setDatePicker(noteData: self.practiceNoteData)
            
            // 天候Pickerにデータをセット
            setWeatherPicker(noteData: self.practiceNoteData)
            
            // テーブルビューの高さ調整
            self.tableViewHeight.constant = 100
            
            // テーブルビューを更新
            self.tableView.reloadData()
        } else {
            // 設定に時間がかかるため、ここでノートIDの設定もしておく。保存時にやるとID設定前にノートが保存されてしまう。
            practiceNoteData.setNewNoteID()
        }
    }
    
    
    
    //MARK:- 変数の宣言
    
    // Picker用ビュー
    var pickerView = UIView()
    var bottomPadding:CGFloat = 0
    var toolbarHeight:CGFloat = 44
    
    // 種別Picker
    let typePicker = UIPickerView()
    let noteType:[String] = ["----","目標設定","練習記録","大会記録"]
    var typeIndex:Int = 2
    
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
    
    // 課題Picker
    let taskPicker = UIPickerView()
    var taskIndex:Int = 0
    
    // データ格納用
    var dataManager = DataManager()
    var practiceNoteData = Note_old()
    
    // 終了フラグ
    var saveFinished:Bool = false
    
    // ノート詳細確認画面からの遷移用
    var previousControllerName:String = ""  // 前のViewController名
    
    // キーボードでテキストフィールドが隠れないための設定用
    var selectedTextView: UITextView?
    var textHeight: CGFloat = 0.0
    let screenSize = UIScreen.main.bounds.size
    var navBarHeight:CGFloat = 44.0
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var taskTableViewHeight: NSLayoutConstraint!
    
    // テキストビュー
    @IBOutlet weak var physicalConditionTextView: UITextView!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    
    // 保存ボタンの処理
    func saveButton() {
        // 対策の有効性コメントの記入チェック
        if self.practiceNoteData.getTaskTitle().count != 0 {
            for num in 0...self.practiceNoteData.getTaskTitle().count - 1 {
//                let cell = taskTableView.cellForRow(at: [0,num]) as! TaskMeasuresTableViewCell
//                if cell.effectivenessTextView.text.isEmpty && cell.checkBox.isSelected {
//                    SVProgressHUD.showError(withStatus: "対策の有効性欄が未記入です")
//                    return
//                }
            }
        }
        
        // 練習ノートデータをFirebaseに保存
        saveNoteData()
        
        // 目標データがなければ作成
        if dataManager.targetDataArray.isEmpty == true {
            // 月間目標データを作成
            saveTargetData(year: self.year, month: self.month)
            
            // フラグ
            saveFinished = true
            
            // 年間目標データを作成
            saveTargetData(year: self.year, month: 13)
        } else {
            // 既に目標登録済みの月を取得(同じ年の)
            var monthArray:[Int] = []
            for num in 0...(dataManager.targetDataArray.count - 1) {
                if dataManager.targetDataArray[num].getYear() == self.year {
                    monthArray.append(dataManager.targetDataArray[num].getMonth())
                }
            }
            // 月間,年間双方の登録がなければ、目標作成
            if monthArray.firstIndex(of: self.month) == nil && monthArray.firstIndex(of: 13) == nil {
                // 月間目標データを作成
                saveTargetData(year: self.year, month: self.month)
                
                // フラグ
                saveFinished = true
                
                // 年間目標データを作成
                saveTargetData(year: self.year, month: 13)
            } else if monthArray.firstIndex(of: self.month) == nil {
                // 年間目標のみ存在する場合
                // フラグ
                saveFinished = true
                
                // 月間目標データを作成
                saveTargetData(year: self.year, month: self.month)
            } else if monthArray.firstIndex(of: 13) == nil {
                // 月間目標のみ存在する場合
                // フラグ
                saveFinished = true
                
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
    
    // 追加ボタンの処理
    @IBAction func addButton(_ sender: Any) {
        // 課題Pickerの初期化
        taskPickerInit()
        
        // 下からPickerを出す
        openPicker(pickerView: pickerView)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // PracticeNoteDetailViewControllerから遷移してきた場合
        if previousControllerName == "PracticeNoteDetailViewController" {
            if tableView.tag == 0 {
                return 2    // 日付セル,天候セルの2つ
            } else {
                return self.practiceNoteData.getTaskTitle().count     // 課題数を返却
            }
        } else {
            if tableView.tag == 0 {
                return 3    // 種別セル,日付セル,天候セルの3つ
            } else {
                return self.practiceNoteData.getTaskTitle().count     // 課題数を返却
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            // セルを取得
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            // 0行目のセル
            if indexPath.row == 0 {
                // PracticeNoteDetailViewControllerから遷移してきた場合
                if previousControllerName == "PracticeNoteDetailViewController" {
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
                // PracticeNoteDetailViewControllerから遷移してきた場合
                if previousControllerName == "PracticeNoteDetailViewController" {
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
        } else {
            // 未解決の課題セルを返却
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskMeasuresTableViewCell", for: indexPath) as! TaskMeasuresTableViewCell
//            cell.addTextViewBorder()
//            cell.initCheckBox()
//            cell.printTaskData(noteData: self.practiceNoteData, at: indexPath.row)
//            cell.createToolBar()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            if indexPath.row == 0 {
                // PracticeNoteDetailViewControllerから遷移してきた場合
                if previousControllerName == "PracticeNoteDetailViewController" {
                    // 日付セルがタップされた時
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    
                    // Pickerの初期化
                    datePickerInit()
                    
                    // 下からPickerを出す
                    openPicker(pickerView: pickerView)
                } else {
                    // 種別セルがタップされた時
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    
                    // Pickerの初期化
                    typeCellPickerInit()
                    
                    // 下からPickerを出す
                    openPicker(pickerView: pickerView)
                }
            } else if indexPath.row == 1 {
                // PracticeNoteDetailViewControllerから遷移してきた場合
                if previousControllerName == "PracticeNoteDetailViewController" {
                    // 天候セルがタップされた時
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    
                    // Pickerの初期化
                    weatherPickerInit()
                    
                    // 下からPickerを出す
                    openPicker(pickerView: pickerView)
                } else {
                    // 日付セルがタップされた時
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    
                    // Pickerの初期化
                    datePickerInit()
                    
                    // 下からPickerを出す
                    openPicker(pickerView: pickerView)
                }
            } else {
                // PracticeNoteDetailViewControllerから遷移してきた場合
                if previousControllerName == "PracticeNoteDetailViewController" {
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                } else {
                    // 天候セルがタップされた時
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    
                    // Pickerの初期化
                    weatherPickerInit()
                    
                    // 下からPickerを出す
                    openPicker(pickerView: pickerView)
                }
            }
        } else {
            // 未解決の課題セルをタップしたときの処理
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            // Pickerをしまう
            closePicker()
        }
    }
    
    // セルの高さ設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0 {
            return 44
        } else {
            return 260
        }
    }
    
    // セルの編集可否の設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0 {
            return false    // 種別,日付,天候セルは編集不可
        } else {
            return true     // 未解決の課題セルは編集可能
        }
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            // 削除処理かどうかの判定
            if editingStyle == UITableViewCell.EditingStyle.delete {
                // practiceNoteDataから削除
                self.practiceNoteData.deleteTask(at: indexPath.row)
                
                // セルを削除
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            }
        }
    }
    
    // deleteの表示名を変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "非表示"
    }
    
    
    
    //MARK:- Pickerの設定
    
    // Pickerの列数を返却
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 1 {
            return 2    // 天候Pickerは天気,気温の2つ
        } else {
            return 1    // 種別、課題Pickerは1つ
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
            return dataManager.taskDataArray.count      // 課題数
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
                return "\(temperature[row])℃"   // 天候Pickerの気温
            } else {
                return nil
            }
        } else {
            return "\(dataManager.taskDataArray[row].getTitle())" // 課題Pickerの項目
        }
    }
    
    // 種別セル初期化メソッド
    func typeCellPickerInit() {
        // 種別Pickerの宣言
        typePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: typePicker.bounds.size.height)
        typePicker.backgroundColor = UIColor.systemGray5
        
        // ビューを追加
        pickerView = UIView(frame: typePicker.bounds)
        pickerView.addSubview(typePicker)
        pickerView.addSubview(createToolBar(#selector(typeDone), #selector(cancelAction)))
        view.addSubview(pickerView)
    }
    
    // キャンセルボタンの処理
    @objc func cancelAction() {
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
            let nextView = storyboard.instantiateViewController(withIdentifier: "AddTargetViewController_old")
            self.present(nextView, animated: false, completion: nil)
            break
        case 2:
            // 練習記録追加画面のまま
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
    
    // 日付Pickerの初期化メソッド
    func datePickerInit() {
        // 日付Pickerの宣言
        datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.backgroundColor = UIColor.systemGray5
        datePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height)
        
        // ビューを追加
        pickerView = UIView(frame: datePicker.bounds)
        pickerView.addSubview(datePicker)
        pickerView.addSubview(createToolBar(#selector(datePickerDone), #selector(cancelAction)))
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
        // 天候Pickerの宣言
        weatherPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: weatherPicker.bounds.size.height)
        weatherPicker.backgroundColor = UIColor.systemGray5

        // ビューを追加
        pickerView = UIView(frame: weatherPicker.bounds)
        pickerView.addSubview(weatherPicker)
        pickerView.addSubview(createToolBar(#selector(weatherDone), #selector(cancelAction)))
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
    
    // 課題Pickerの初期化メソッド
    func taskPickerInit() {
        // 課題Pickerの宣言
        taskPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: taskPicker.bounds.size.height)
        taskPicker.backgroundColor = UIColor.systemGray5
        
        // ビューを追加
        pickerView = UIView(frame: taskPicker.bounds)
        pickerView.addSubview(taskPicker)
        pickerView.addSubview(createToolBar("追加", #selector(taskPickerDone), #selector(cancelAction)))
        view.addSubview(pickerView)
    }
    
    // 完了ボタンの処理
    @objc func taskPickerDone() {
        // 選択されたIndexを取得
        taskIndex = taskPicker.selectedRow(inComponent: 0)
        
        // 課題が未登録の場合は何もしない
        if dataManager.taskDataArray.isEmpty {
            // 何もしない
        } else {
            // 既に表示している課題であれば追加しない
            if self.practiceNoteData.getTaskTitle().firstIndex(of: dataManager.taskDataArray[taskIndex].getTitle()) == nil {
                // noteDataに追加
                self.practiceNoteData.addTask(taskData: dataManager.taskDataArray[taskIndex])
                
                // セルを挿入
                self.taskTableView.insertRows(at: [IndexPath(row: practiceNoteData.getTaskTitle().count - 1, section: 0)], with: .fade)
                
                // 課題数によってテーブルビューの高さを設定
                self.taskTableView?.layoutIfNeeded()
                self.taskTableView?.updateConstraints()
                self.taskTableViewHeight.constant = CGFloat(self.taskTableView.contentSize.height)
                
                // AddPracticeNoteViewControllerオブジェクトを取得
                let obj = self.parent as! AddPracticeNoteViewController_old
                
                // containerViewの高さを設定
                obj.setContainerViewHeight(height: self.taskTableView.contentSize.height)
            } else {
                SVProgressHUD.showError(withStatus: "既に追加されています。")
            }
        }
        // Pickerをしまう
        closePicker()
    }
    
    // Pickerを画面下から開くメソッド
    func openPicker(pickerView picker:UIView) {
        // 現在のスクロール位置（最下点）,Pickerの座標を取得
        let obj = self.parent as! AddPracticeNoteViewController_old
        let scrollPotiton = obj.getScrollPosition()
        
        // 下からPickerを出す
        openPicker(pickerView, scrollPotiton, bottomPadding)
    }
    
    // Pickerをしまうメソッド
    func closePicker() {
        closePicker(pickerView)
    }
    
    
    
    //MARK:- データベース関連
    
    // Firebaseから目標データを取得するメソッド
    func loadTargetData() {
        dataManager.getTargetData({})
    }
    
    // 課題データを取得するメソッド
    func loadTaskData() {
        // 未解決の課題データを取得
        dataManager.getUnresolvedTaskData({
            // practiceNoteDataに反映
            if self.previousControllerName == "PracticeNoteDetailViewController" {
            } else {
                for databaseTaskData in self.dataManager.taskDataArray {
                    // 最有力の対策がない課題(対策データが存在しない)は連動できないため、読み込まない
                    if databaseTaskData.getMeasuresPriority().isEmpty {
                        // 読み込まない
                    } else {
                        self.practiceNoteData.addTask(taskData: databaseTaskData)
                    }
                }
            }
            
            // テーブルビューの更新
            self.taskTableView?.reloadData()
            
            // 課題数によってテーブルビューの高さを設定
            self.taskTableView?.layoutIfNeeded()
            self.taskTableView?.updateConstraints()
            self.taskTableViewHeight.constant = CGFloat(self.taskTableView.contentSize.height)
            
            // AddPracticeNoteViewControllerオブジェクトを取得
            if let obj:AddPracticeNoteViewController_old = self.parent as? AddPracticeNoteViewController_old {
                // containerViewの高さを設定
                obj.setContainerViewHeight(height: self.taskTableView.contentSize.height)
                
                // 保存ボタンを有効にする
                obj.saveButtonEnable()
            }
        })
    }
    
    // Firebaseにノートデータを保存するメソッド
    func saveNoteData() {
        // ノートタイプを指定
        practiceNoteData.setNoteType("練習記録")
        
        // Pickerの選択項目をセット
        practiceNoteData.setYear(year)
        practiceNoteData.setMonth(month)
        practiceNoteData.setDate(date)
        practiceNoteData.setDay(day)
        practiceNoteData.setWeather(weather[weatherIndex])
        practiceNoteData.setTemperature(temperature[temperatureIndex])
        
        // 入力テキストをセット
        practiceNoteData.setPhysicalCondition(physicalConditionTextView.text!)
        practiceNoteData.setPurpose(purposeTextView.text!)
        practiceNoteData.setDetail(detailTextView.text!)
        practiceNoteData.setReflection(reflectionTextView.text!)
        
        // 対策の有効性コメントをセット
        var measuresEffectiveness:[String] = []
        if self.practiceNoteData.getTaskTitle().isEmpty {
            // 何もしない
        } else {
            for num in 0...self.practiceNoteData.getTaskTitle().count - 1 {
                // 対策の有効性コメントをセット
                let cell = taskTableView.cellForRow(at: [0,num]) as! TaskMeasuresTableViewCell
                measuresEffectiveness.append(cell.effectivenessTextView.text)
                
                // チェックが入っていればTaskDataの有効性コメントに追加
//                if cell.checkBox.isSelected {
                    // 課題タイトルの配列を作成
                    var taskTitleArray:[String] = []
                    if self.dataManager.taskDataArray.count <= 0 {
                        continue
                    }
                    for num in 0...self.dataManager.taskDataArray.count - 1 {
                        taskTitleArray.append(self.dataManager.taskDataArray[num].getTitle())
                    }
                    
                    // 該当する課題データが格納されているindexを取得
                    var index:Int = 0
                    for num in 0...taskTitleArray.count - 1 {
                        if taskTitleArray[num] == cell.taskTitleLabel.text! {
                            index = num
                        }
                    }
                    
                    // そのindexの課題データを更新
                    self.dataManager.taskDataArray[index].addEffectiveness(title: self.practiceNoteData.getMeasuresTitle()[num], effectiveness: cell.effectivenessTextView.text,noteID: self.practiceNoteData.getNoteID())
                    
                    // データ更新
                    self.updateTaskData(task: self.dataManager.taskDataArray[index])
//                }
            }
        }
        practiceNoteData.setMeasuresEffectiveness(measuresEffectiveness)
        
        // 既存ノートを更新する場合
        if previousControllerName == "PracticeNoteDetailViewController" {
            dataManager.updateNoteData(practiceNoteData, {
                if self.previousControllerName == "PracticeNoteDetailViewController" {
                    // ノート画面に遷移
                    let storyboard: UIStoryboard = self.storyboard!
                    let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                    self.present(nextView, animated: false, completion: nil)
                }
            })
        } else {
            dataManager.saveNoteData(practiceNoteData, {})
        }
    }
    
    // Firebaseに目標データを保存するメソッド（新規目標追加時のみ使用）
    func saveTargetData(year selectedYear:Int, month selectedMonth:Int) {
        dataManager.saveTargetData(selectedYear, selectedMonth, "", {
            // 最後の保存であればモーダルを閉じる
            if self.saveFinished == true {
                // ストーリーボードを取得
                let storyboard: UIStoryboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                // ノート画面に遷移
                self.present(nextView, animated: false, completion: nil)
            }
        })
    }
    
    // Firebaseの課題データを更新するメソッド
    func updateTaskData(task taskData:Task_old) {
        dataManager.updateTaskData(taskData, {})
    }
    
    
    
    //MARK:- その他のメソッド
    
    // ノートデータのテキストをセットするメソッド
    func setTextData(noteData note:Note_old) {
        self.physicalConditionTextView.text = note.getPhysicalCondition()
        self.purposeTextView.text = note.getPurpose()
        self.detailTextView.text = note.getDetail()
        self.reflectionTextView.text = note.getReflection()
    }
    
    // ノートの日付をDatePickerにセットするメソッド
    func setDatePicker(noteData note:Note_old) {
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
    func setWeatherPicker(noteData note:Note_old) {
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
    
    // 現在時刻を取得するメソッド
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
        print("\(year)/\(month)/\(date)/\(day)")
        
        return returnText
    }
    
    // テキストビューに枠線を追加するメソッド
    func addTextViewBorder() {
        physicalConditionTextView.layer.borderColor = UIColor.systemGray.cgColor
        physicalConditionTextView.layer.borderWidth = 1.0
        purposeTextView.layer.borderColor = UIColor.systemGray.cgColor
        purposeTextView.layer.borderWidth = 1.0
        detailTextView.layer.borderColor = UIColor.systemGray.cgColor
        detailTextView.layer.borderWidth = 1.0
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
        notification.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        let obj = self.parent as! AddPracticeNoteViewController_old
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
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
}

