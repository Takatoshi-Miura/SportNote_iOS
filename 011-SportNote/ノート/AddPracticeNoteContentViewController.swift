//
//  AddPracticeNoteViewController.swift
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
        tableView.delegate       = self
        tableView.dataSource     = self
        taskTableView.dataSource = self
        taskTableView.delegate   = self
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
        
        // 種別Pickerの宣言
        typePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: typePicker.bounds.size.height)
        typePicker.backgroundColor = UIColor.systemGray5
        
        // 日付Pickerの宣言
        datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
        datePicker.backgroundColor = UIColor.systemGray5
        datePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height)
        
        // 天候Pickerの宣言
        weatherPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: weatherPicker.bounds.size.height)
        weatherPicker.backgroundColor = UIColor.systemGray5
        
        // 課題Pickerの宣言
        taskPicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: taskPicker.bounds.size.height)
        taskPicker.backgroundColor = UIColor.systemGray5
        
        // 初期値の設定(気温20度に設定)
        weatherPicker.selectRow(60, inComponent: 1, animated: true)
        selectedDate = getCurrentPickerTime()
        
        // テキストビューの枠線付け
        physicalConditionTextView.layer.borderColor = UIColor.systemGray.cgColor
        physicalConditionTextView.layer.borderWidth = 1.0
        purposeTextView.layer.borderColor = UIColor.systemGray.cgColor
        purposeTextView.layer.borderWidth = 1.0
        detailTextView.layer.borderColor = UIColor.systemGray.cgColor
        detailTextView.layer.borderWidth = 1.0
        reflectionTextView.layer.borderColor = UIColor.systemGray.cgColor
        reflectionTextView.layer.borderWidth = 1.0
        
        // キーボードでテキストフィールドが隠れない設定
        self.configureObserver()
        
        // ツールバーを作成
        createToolBar()
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
            
            // テーブルビューを更新
            self.tableView.reloadData()
            
            // 課題データ取得
            for index in 0...self.practiceNoteData.getTaskTitle().count - 1 {
                self.loadTaskData(taskTitle: self.practiceNoteData.getTaskTitle()[index], measuresTitle: self.practiceNoteData.getMeasuresTitle()[index], measuresEffectiveness: self.practiceNoteData.getMeasuresEffectiveness()[index])
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.taskTableView?.reloadData()
                
                // 課題数によってテーブルビューの高さを設定
                self.taskTableView?.layoutIfNeeded()
                self.taskTableView?.updateConstraints()
                self.taskTableViewHeight.constant = CGFloat(self.taskTableView.contentSize.height)
                
                // AddPracticeNoteViewControllerオブジェクトを取得
                let obj = self.parent as! AddPracticeNoteViewController
                
                // containerViewの高さを設定
                obj.setContainerViewHeight(height: self.taskTableView.contentSize.height)
            }
        } else {
            // 設定に時間がかかるため、ここでノートIDの設定もしておく。保存時にやるとID設定前にノートが保存されてしまう。
            practiceNoteData.setNewNoteID()
        }
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
    var task = [TaskData]()
    var taskIndex:Int = 0
    
    // データ格納用
    var targetDataArray  = [TargetData]()
    var taskDataArray    = [TaskData]()
    var practiceNoteData = NoteData()
    
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
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var taskTableViewHeight: NSLayoutConstraint!
    
    // テキストビュー
    @IBOutlet weak var physicalConditionTextView: UITextView!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    
    // 保存ボタンの処理
    func saveButton() {
        // 練習ノートデータをFirebaseに保存
        saveNoteData()
        
        // 目標データがなければ作成
        if targetDataArray.isEmpty == true {
            // 月間目標データを作成
            saveTargetData(year: self.year, month: self.month)
            
            // フラグ
            saveFinished = true
            
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
        // 課題Pickerの初期化＆呼び出し
        taskPickerInit()
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // PracticeNoteDetailViewControllerから遷移してきた場合
        if previousControllerName == "PracticeNoteDetailViewController" {
            if tableView.tag == 0 {
                return 2    // 日付セル,天候セルの2つ
            } else {
                return taskDataArray.count     // 課題数を返却
            }
        } else {
            if tableView.tag == 0 {
                return 3    // 種別セル,日付セル,天候セルの3つ
            } else {
                return taskDataArray.count     // 未解決の課題の数
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
            cell.addTextViewBorder()
            cell.initCheckBox()
            // PracticeNoteDetailViewControllerから遷移してきた場合
            if previousControllerName == "PracticeNoteDetailViewController" {
                if self.taskDataArray.isEmpty == false {
                    cell.previousControllerName = "PracticeNoteDetailViewController"
                    cell.printTaskData(taskData: taskDataArray[indexPath.row])
                }
            } else {
                cell.printTaskData(taskData: taskDataArray[indexPath.row])
            }
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
                    
                    // Pickerの初期化＆呼び出し
                    datePickerInit()
                } else {
                    // 種別セルがタップされた時
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    
                    // Pickerの初期化＆呼び出し
                    typeCellPickerInit()
                }
            } else if indexPath.row == 1 {
                // PracticeNoteDetailViewControllerから遷移してきた場合
                if previousControllerName == "PracticeNoteDetailViewController" {
                    // 天候セルがタップされた時
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    
                    // Pickerの初期化＆呼び出し
                    weatherPickerInit()
                } else {
                    // 日付セルがタップされた時
                    // タップしたときの選択色を消去
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    
                    // Pickerの初期化＆呼び出し
                    datePickerInit()
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
                    
                    // Pickerの初期化＆呼び出し
                    weatherPickerInit()
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
                // taskDataArrayから削除
                self.taskDataArray.remove(at:indexPath.row)
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
            return task.count               // 課題数
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
            return "\(task[row].getTaskTitle())" // 課題Pickerの項目
        }
    }
    
    // 種別セル初期化メソッド
    func typeCellPickerInit() {
        // ビューの初期化
        pickerView.removeFromSuperview()
        
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
        
        // 現在のスクロール位置（最下点）,Pickerの座標を取得
        let obj = self.parent as! AddPracticeNoteViewController
        let scrollPotiton = obj.getScrollPosition()
        let pickerPosition = obj.getPickerPosition()
        
        // 下からPickerを呼び出す
        pickerView.frame.origin.y = pickerPosition
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = scrollPotiton - self.pickerView.bounds.size.height - 60
        }
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
        // ビューの初期化
        pickerView.removeFromSuperview()
        
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
        
        // 現在のスクロール位置（最下点）,Pickerの座標を取得
        let obj = self.parent as! AddPracticeNoteViewController
        let scrollPotiton = obj.getScrollPosition()
        let pickerPosition = obj.getPickerPosition()
        
        // 下からPickerを呼び出す
        pickerView.frame.origin.y = pickerPosition
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = scrollPotiton - self.pickerView.bounds.size.height - 60
        }
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
        
        // 現在のスクロール位置（最下点）,Pickerの座標を取得
        let obj = self.parent as! AddPracticeNoteViewController
        let scrollPotiton = obj.getScrollPosition()
        let pickerPosition = obj.getPickerPosition()
        
        // 下からPickerを呼び出す
        pickerView.frame.origin.y = pickerPosition
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = scrollPotiton - self.pickerView.bounds.size.height - 60
        }
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
        // ビューの初期化
        pickerView.removeFromSuperview()
        
        // ツールバーの宣言
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.taskPickerDone))
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.typeCancel))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        
        // ビューを追加
        pickerView = UIView(frame: taskPicker.bounds)
        pickerView.addSubview(taskPicker)
        pickerView.addSubview(toolbar)
        view.addSubview(pickerView)
        
        // 現在のスクロール位置（最下点）,Pickerの座標を取得
        let obj = self.parent as! AddPracticeNoteViewController
        let scrollPotiton = obj.getScrollPosition()
        let pickerPosition = obj.getPickerPosition()
        
        // 下からPickerを呼び出す
        pickerView.frame.origin.y = pickerPosition
        UIView.animate(withDuration: 0.3) {
            self.pickerView.frame.origin.y = scrollPotiton - self.pickerView.bounds.size.height - 60
        }
    }
    
    // 完了ボタンの処理
    @objc func taskPickerDone() {
        // 選択されたIndexを取得
        taskIndex = taskPicker.selectedRow(inComponent: 0)
        
        // 課題タイトルの配列を作成
        var taskDataTitleArray:[String] = []
        if taskDataArray.isEmpty == false {
            for num in 0...taskDataArray.count - 1 {
                taskDataTitleArray.append(self.taskDataArray[num].getTaskTitle())
            }
        }
        
        // 既に表示している課題であれば追加しない
        if taskDataTitleArray.firstIndex(of: task[taskIndex].getTaskTitle()) == nil {
            // taskDataArrayに選択された課題を追加
            self.taskDataArray.insert(task[taskIndex], at: 0)
            
            // テーブルを更新
            self.taskTableView.reloadData()
            
            // 課題数によってテーブルビューの高さを設定
            self.taskTableView?.layoutIfNeeded()
            self.taskTableView?.updateConstraints()
            self.taskTableViewHeight.constant = CGFloat(self.taskTableView.contentSize.height)
            
            // AddPracticeNoteViewControllerオブジェクトを取得
            let obj = self.parent as! AddPracticeNoteViewController
            
            // containerViewの高さを設定
            obj.setContainerViewHeight(height: self.taskTableView.contentSize.height)
        } else {
            SVProgressHUD.showError(withStatus: "既に追加されています。")
        }
        
        // Pickerをしまう
        closePicker()
           
        // テーブルビューを更新
        taskTableView.reloadData()
    }
    
    // Pickerをしまうメソッド
    func closePicker() {
        // 現在のスクロール位置（最下点）,Pickerの座標を取得
        let obj = self.parent as! AddPracticeNoteViewController
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
    
    
    
    
    //MARK:- その他のメソッド
    
    // ノートデータのテキストをセットするメソッド
    func setTextData(noteData note:NoteData) {
        self.physicalConditionTextView.text = note.getPhysicalCondition()
        self.purposeTextView.text = note.getPurpose()
        self.detailTextView.text = note.getDetail()
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
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
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
        let obj = self.parent as! AddPracticeNoteViewController
        let scrollPotiton = obj.getScrollPosition()
        let keyboardHeight = rect.size.height
        
        // textViewDidBeginEditingが実行されるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // スクロールする高さを計算
            let hiddenHeight = keyboardHeight + self.textHeight + self.navBarHeight - scrollPotiton
            
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
        purposeTextView.inputAccessoryView = toolBar
        detailTextView.inputAccessoryView = toolBar
        reflectionTextView.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // Firebaseから目標データを取得するメソッド
    func loadTargetData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // targetDataArrayを初期化
        targetDataArray = []
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        
        // 現在のユーザーの目標データを取得する
        db.collection("TargetData")
            .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
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
    
    // 課題データを取得するメソッド
    func loadTaskData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーの未解決課題データ取得
        // ログインユーザーの課題データで、かつisDeletedがfalseの課題を取得
        // 課題画面にて、古い課題を下、新しい課題を上に表示させるため、taskIDの降順にソートする
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
            .whereField("isDeleted", isEqualTo: false)
            .whereField("taskAchievement", isEqualTo: false)
            .order(by: "taskID", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDataCollection = document.data()
                
                    // 取得データを基に、課題データを作成
                    let databaseTaskData = TaskData()
                    databaseTaskData.setTaskID(taskDataCollection["taskID"] as! Int)
                    databaseTaskData.setTaskTitle(taskDataCollection["taskTitle"] as! String)
                    databaseTaskData.setTaskCause(taskDataCollection["taskCause"] as! String)
                    databaseTaskData.setTaskAchievement(taskDataCollection["taskAchievement"] as! Bool)
                    databaseTaskData.setIsDeleted(taskDataCollection["isDeleted"] as! Bool)
                    databaseTaskData.setUserID(taskDataCollection["userID"] as! String)
                    databaseTaskData.setCreated_at(taskDataCollection["created_at"] as! String)
                    databaseTaskData.setUpdated_at(taskDataCollection["updated_at"] as! String)
                    databaseTaskData.setMeasuresData(taskDataCollection["measuresData"] as! [String:[[String:Int]]])
                    databaseTaskData.setMeasuresPriority(taskDataCollection["measuresPriority"] as! String)
                    
                    // 課題データを格納
                    self.taskDataArray.append(databaseTaskData)
                }
                // 課題データを格納
                self.task = self.taskDataArray
                
                // PracticeNoteDetailViewControllerから遷移してきた場合
                if self.previousControllerName == "PracticeNoteDetailViewController" {
                    // taskDataArrayをリセット（後にpracticeNoteDataの課題をセットするため）
                    self.taskDataArray = []
                }
                
                // テーブルビューの更新
                self.taskTableView?.reloadData()
                
                // 課題数によってテーブルビューの高さを設定
                self.taskTableView?.layoutIfNeeded()
                self.taskTableView?.updateConstraints()
                self.taskTableViewHeight.constant = CGFloat(self.taskTableView.contentSize.height)
                
                // AddPracticeNoteViewControllerオブジェクトを取得
                let obj = self.parent as! AddPracticeNoteViewController
                
                // containerViewの高さを設定
                obj.setContainerViewHeight(height: self.taskTableView.contentSize.height)
                
                // 保存ボタンを有効にする
                obj.saveButtonEnable()
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // 課題データを取得するメソッド
    func loadTaskData(taskTitle title:String,measuresTitle measure:String,measuresEffectiveness effectiveness:String) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // practiceNoteDataが所有している課題データを取得
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
            .whereField("taskTitle", isEqualTo: title)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDataCollection = document.data()
                    
                    // measuresDataオブジェクトを作成
                    let obj:[String:[[String:Int]]] = [measure:[[effectiveness:0]]]
                    
                    // 取得データを基に、課題データを作成
                    let databaseTaskData = TaskData()
                    databaseTaskData.setTaskID(taskDataCollection["taskID"] as! Int)
                    databaseTaskData.setTaskTitle(title)
                    databaseTaskData.setTaskCause(taskDataCollection["taskCause"] as! String)
                    databaseTaskData.setTaskAchievement(taskDataCollection["taskAchievement"] as! Bool)
                    databaseTaskData.setIsDeleted(taskDataCollection["isDeleted"] as! Bool)
                    databaseTaskData.setUserID(taskDataCollection["userID"] as! String)
                    databaseTaskData.setCreated_at(taskDataCollection["created_at"] as! String)
                    databaseTaskData.setUpdated_at(taskDataCollection["updated_at"] as! String)
                    databaseTaskData.setMeasuresData(obj)
                    databaseTaskData.setMeasuresPriority(taskDataCollection["measuresPriority"] as! String)
                    
                    // 課題データを格納
                    self.taskDataArray.append(databaseTaskData)
                }
                // テーブル更新
                self.taskTableView.reloadData()
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // Firebaseにノートデータを保存するメソッド
    func saveNoteData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 大会ノートデータを作成
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
        
        // 対策データをセット
        var taskTitle:[String] = []
        var measuresTitle:[String] = []
        var measuresEffectiveness:[String] = []
        
        if previousControllerName == "PracticeNoteDetailViewController" {
            // 更新日時に現在時刻をセット
            practiceNoteData.setUpdated_at(getCurrentTime())
            
        } else {
            // 課題を全て非表示にした際のエラー対策
            if self.taskDataArray.isEmpty == true {
                // 何もしない
            } else {
                for num in 0...self.taskDataArray.count - 1 {
                    // 課題タイトル
                    taskTitle.append(self.taskDataArray[num].getTaskTitle())
                    
                    // 対策タイトル
                    let measures = self.taskDataArray[num].getMeasuresPriority()
                    measuresTitle.append(measures)
                    
                    // 対策の有効性
                    let cell = taskTableView.cellForRow(at: [0,num]) as! TaskMeasuresTableViewCell
                    measuresEffectiveness.append(cell.effectivenessTextView.text)
                    
                    // チェックが入っていればTaskDataの有効性コメントに追加
                    if cell.checkBox.isSelected {
                        self.taskDataArray[num].addEffectiveness(title: measures, effectiveness: cell.effectivenessTextView.text,noteID: self.practiceNoteData.getNoteID())
                        self.updateTaskData(task: self.taskDataArray[num])
                    }
                }
            }
            practiceNoteData.setTaskTitle(taskTitle)
            practiceNoteData.setMeasuresTitle(measuresTitle)
            practiceNoteData.setMeasuresEffectiveness(measuresEffectiveness)
            
            // ユーザーUIDをセット
            practiceNoteData.setUserID(Auth.auth().currentUser!.uid)
            
            // 現在時刻をセット
            practiceNoteData.setCreated_at(getCurrentTime())
            practiceNoteData.setUpdated_at(practiceNoteData.getCreated_at())
        
        }
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("NoteData").document("\(practiceNoteData.getUserID())_\(practiceNoteData.getNoteID())").setData([
            "noteID"                : practiceNoteData.getNoteID(),
            "noteType"              : practiceNoteData.getNoteType(),
            "year"                  : practiceNoteData.getYear(),
            "month"                 : practiceNoteData.getMonth(),
            "date"                  : practiceNoteData.getDate(),
            "day"                   : practiceNoteData.getDay(),
            "weather"               : practiceNoteData.getWeather(),
            "temperature"           : practiceNoteData.getTemperature(),
            "physicalCondition"     : practiceNoteData.getPhysicalCondition(),
            "purpose"               : practiceNoteData.getPurpose(),
            "detail"                : practiceNoteData.getDetail(),
            "target"                : practiceNoteData.getTarget(),
            "consciousness"         : practiceNoteData.getConsciousness(),
            "result"                : practiceNoteData.getResult(),
            "reflection"            : practiceNoteData.getReflection(),
            "taskTitle"             : practiceNoteData.getTaskTitle(),
            "measuresTitle"         : practiceNoteData.getMeasuresTitle(),
            "measuresEffectiveness" : practiceNoteData.getMeasuresEffectiveness(),
            "isDeleted"             : practiceNoteData.getIsDeleted(),
            "userID"                : practiceNoteData.getUserID(),
            "created_at"            : practiceNoteData.getCreated_at(),
            "updated_at"            : practiceNoteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                
                // PracticeNoteDetailViewControllerから遷移してきた場合
                if self.previousControllerName == "PracticeNoteDetailViewController" {
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
            
        // 目標データを作成
        let targetData = TargetData()
        
        // 年月をセット
        targetData.setYear(selectedYear)
        targetData.setMonth(selectedMonth)
            
        // ユーザーUIDをセット
        targetData.setUserID(Auth.auth().currentUser!.uid)
        
        // 現在時刻をセット
        targetData.setCreated_at(getCurrentTime())
        targetData.setUpdated_at(targetData.getCreated_at())
            
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("TargetData").document("\(Auth.auth().currentUser!.uid)_\(targetData.getYear())_\(targetData.getMonth())").setData([
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
    
    // Firebaseの課題データを更新するメソッド
    func updateTaskData(task taskData:TaskData) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 更新日時を現在時刻にする
        taskData.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let database = db.collection("TaskData").document("\(Auth.auth().currentUser!.uid)_\(taskData.getTaskID())")

        // 変更する可能性のあるデータのみ更新
        database.updateData([
            "taskTitle"      : taskData.getTaskTitle(),
            "taskCause"      : taskData.getTaskCouse(),
            "taskAchievement": taskData.getTaskAchievement(),
            "isDeleted"      : taskData.getIsDeleted(),
            "updated_at"     : taskData.getUpdated_at(),
            "measuresData"   : taskData.getMeasuresData(),
            "measuresPriority" : taskData.getMeasuresPriority()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
            }
        }
    }
    
    

}

