//
//  AddPracticeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/27.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol AddPracticeNoteViewControllerDelegate: AnyObject {
    // モーダルを閉じる時の処理
    func addPracticeNoteVCDismiss(_ viewController: UIViewController)
    // ノート追加時の処理
    func addPracticeNoteVCAddNote(_ viewController: UIViewController)
    // ノート削除時の処理
    func addPracticeNoteVCDeleteNote()
}

class AddPracticeNoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var reflectionLabel: UILabel!
    @IBOutlet weak var conditionTextView: UITextView!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateTableView: UITableView!
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var scrollViewTop: NSLayoutConstraint!
    @IBOutlet weak var taskTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    private var taskArray = [TaskForAddNote]()
    private var displayTaskArray = [TaskForAddNote]()
    private var realmMemoArray = [Memo]()
    var delegate: AddPracticeNoteViewControllerDelegate?
    var isViewer = false
    var realmNote = Note()
    
    private var pickerView = UIView()
    private var datePicker = UIDatePicker()
    private var weatherPicker = UIPickerView()
    private var taskPicker = UIPickerView()
    private let temperature: [Int] = (-40...40).map { $0 }
    private var selectedDate = Date()
    private var selectedWeather: [String : Int] = [TITLE_WEATHER: 0 ,TITLE_TEMPERATURE: 0]
    
    private enum CellType: Int, CaseIterable {
        case date
        case weather
    }
    
    private enum TableViewType: Int, CaseIterable {
        case date
        case task
    }
    
    private enum PickerType: Int, CaseIterable {
        case date
        case weather
        case task
    }
    
    private enum TextViewType: Int, CaseIterable {
        case condition
        case purpose
        case detail
        case reflection
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initNavigation()
        initTableView()
        initDatePicker()
        initWeatherPicker()
        initTaskPicker()
        initTaskData()
        resizeScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        datePicker.frame.size.width = self.view.bounds.size.width
        weatherPicker.frame.size.width = self.view.bounds.size.width
        taskPicker.frame.size.width = self.view.bounds.size.width
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !isViewer {
            return
        }
        // メモの更新(追加はできない仕様)
        if !realmMemoArray.isEmpty {
            for (index, memo) in realmMemoArray.enumerated() {
                // 入力されている場合のみ作成
                let cell = taskTableView.cellForRow(at: [0, index]) as! TaskCellForAddNote
                if cell.effectivenessTextView.text.isEmpty {
                    continue
                } else {
                    let realmManager = RealmManager()
                    realmManager.updateMemoDetail(memoID: memo.memoID, detail: cell.effectivenessTextView.text!)
                    // Firebaseに送信
                    if Network.isOnline() {
                        let firebaseManager = FirebaseManager()
                        firebaseManager.updateMemo(memo: memo)
                    }
                }
            }
        }
        // Firebaseに送信
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.updateNote(note: realmNote)
        }
    }
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_ADD_PRACTICE_NOTE
        conditionLabel.text = TITLE_CONDITION
        purposeLabel.text = TITLE_PRACTICE_PURPOSE
        detailLabel.text = TITLE_DETAIL
        taskLabel.text = TITLE_TACKLED_TASK
        reflectionLabel.text = TITLE_REFLECTION
        addButton.setTitle(TITLE_ADD, for: .normal)
        
        initTextView(textView: conditionTextView, doneAction: #selector(tapOkButton(_:)))
        initTextView(textView: purposeTextView, doneAction: #selector(tapOkButton(_:)))
        initTextView(textView: detailTextView, doneAction: #selector(tapOkButton(_:)))
        initTextView(textView: reflectionTextView, doneAction: #selector(tapOkButton(_:)))
        conditionTextView.tag = TextViewType.condition.rawValue
        purposeTextView.tag = TextViewType.purpose.rawValue
        detailTextView.tag = TextViewType.detail.rawValue
        reflectionTextView.tag = TextViewType.reflection.rawValue
        
        if isViewer {
            naviBar.isHidden = true
            addButton.isHidden = true
            scrollViewTop.constant = -44
            // ノート内容を反映
            conditionTextView.text = realmNote.condition
            purposeTextView.text = realmNote.purpose
            detailTextView.text = realmNote.detail
            reflectionTextView.text = realmNote.reflection
        }
    }
    
    /// キーボード、Pickerを隠す
    @objc func tapOkButton(_ sender: UIButton){
        self.view.endEditing(true)
        closePicker(pickerView)
        if let index = dateTableView.indexPathForSelectedRow {
            dateTableView.deselectRow(at: index, animated: true)
        }
    }
    
    private func initNavigation() {
        if !isViewer {
            return
        }
        self.title = TITLE_NOTE_DETAIL
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        navigationItems.append(deleteButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    private func initTableView() {
        dateTableView.tag = TableViewType.date.rawValue
        taskTableView.tag = TableViewType.task.rawValue
        dateTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        taskTableView.register(UINib(nibName: "TaskCellForAddNote", bundle: nil), forCellReuseIdentifier: "TaskCellForAddNote")
        if #available(iOS 15.0, *) {
            dateTableView.sectionHeaderTopPadding = 0
            taskTableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// 課題データの取得
    private func initTaskData() {
        let realmManager = RealmManager()
        taskArray = realmManager.getTaskArrayForAddNoteView()
        
        if isViewer {
            // ノートと連動している課題を取得
            displayTaskArray = realmManager.getTaskArrayForAddNoteView(noteID: realmNote.noteID)
            realmMemoArray = realmManager.getMemo(noteID: realmNote.noteID)
        } else {
            // 未解決の課題を取得
            displayTaskArray = realmManager.getTaskArrayForAddNoteView()
        }
    }
    
    /// スクロール領域を調整
    private func resizeScrollView() {
        taskTableViewHeight.constant = CGFloat(displayTaskArray.count * 200)
        scrollViewHeight.constant = CGFloat(1000 + displayTaskArray.count * 200)
    }
    
    
    // MARK: - Action
    
    /// ノートを削除
    @objc func deleteNote() {
        showDeleteAlert(title: TITLE_DELETE_NOTE, message: MESSAGE_DELETE_NOTE, OKAction: {
            let realmManager = RealmManager()
            realmManager.updateNoteIsDeleted(noteID: self.realmNote.noteID)
            realmManager.updateMemoIsDeleted(noteID: self.realmNote.noteID)
            self.delegate?.addPracticeNoteVCDeleteNote()
        })
    }
    
    /// 課題追加ボタン
    @IBAction func tapAddButton(_ sender: Any) {
        // 未解決の課題が一つもない場合はアラート
        if taskArray.isEmpty {
            showErrorAlert(message: TASK_EMPTY_ERROR)
            return
        }
        
        // 課題Pickerを開く
        closePicker(pickerView)
        pickerView = UIView(frame: taskPicker.bounds)
        pickerView.addSubview(taskPicker)
        pickerView.addSubview(createToolBar(#selector(taskPickerDoneAction), #selector(taskPickerCancelAction)))
        openPicker(pickerView)
    }
    
    /// キャンセルボタン
    @IBAction func tapCancelButton(_ sender: Any) {
        if conditionTextView.text.isEmpty &&
            purposeTextView.text.isEmpty &&
            detailTextView.text.isEmpty &&
            reflectionTextView.text.isEmpty
        {
            self.delegate?.addPracticeNoteVCDismiss(self)
        } else {
            showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                self.delegate?.addPracticeNoteVCDismiss(self)
            })
        }
    }
    
    /// 保存ボタン
    @IBAction func tapSaveButton(_ sender: Any) {
        // 練習ノートデータを作成＆保存
        let practiceNote = Note()
        practiceNote.noteType = NoteType.practice.rawValue
        practiceNote.date = selectedDate
        practiceNote.weather = Weather.allCases[selectedWeather[TITLE_WEATHER]!].rawValue
        practiceNote.temperature = temperature[selectedWeather[TITLE_TEMPERATURE]!]
        practiceNote.condition = conditionTextView.text
        practiceNote.purpose = purposeTextView.text
        practiceNote.detail = detailTextView.text
        practiceNote.reflection = reflectionTextView.text
        
        let realmManager = RealmManager()
        if !realmManager.createRealm(object: practiceNote) {
            showErrorAlert(message: ERROR_MESSAGE_NOTE_CREATE_FAILED)
            return
        }
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.saveNote(note: practiceNote, completion: {})
        }
        
        // メモを作成＆保存
        if !displayTaskArray.isEmpty {
            for (index, _) in displayTaskArray.enumerated() {
                // 入力されている場合のみ作成
                let cell = taskTableView.cellForRow(at: [0, index]) as! TaskCellForAddNote
                if cell.effectivenessTextView.text.isEmpty {
                    continue
                } else {
                    let memo = Memo()
                    memo.measuresID = cell.measures.measuresID
                    memo.noteID = practiceNote.noteID
                    memo.detail = cell.effectivenessTextView.text
                    
                    if !realmManager.createRealm(object: memo) {
                        showErrorAlert(message: ERROR_MESSAGE_NOTE_CREATE_FAILED)
                        return
                    }
                    if Network.isOnline() {
                        let firebaseManager = FirebaseManager()
                        firebaseManager.saveMemo(memo: memo, completion: {})
                    }
                }
            }
        }
        
        self.delegate?.addPracticeNoteVCAddNote(self)
    }
    
}

extension AddPracticeNoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            return 2
        case .task:
            return displayTaskArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            return 44
        case .task:
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.detailTextLabel?.textColor = UIColor.systemGray
            cell.accessoryType = .disclosureIndicator
            
            switch CellType.allCases[indexPath.row] {
            case .date:
                cell.textLabel!.text = TITLE_DATE
                cell.detailTextLabel!.text = getDatePickerDate(datePicker: datePicker, format: "yyyy/M/d (E)")
            case .weather:
                cell.textLabel!.text = TITLE_WEATHER
                cell.detailTextLabel!.text = "\(Weather.allCases[selectedWeather[TITLE_WEATHER]!].title) \(temperature[selectedWeather[TITLE_TEMPERATURE]!])℃"
            }
            return cell
        case .task:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellForAddNote", for: indexPath) as! TaskCellForAddNote
            cell.printInfo(task: displayTaskArray[indexPath.row])
            if isViewer {
                cell.printMemo(memo: realmMemoArray[indexPath.row])
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            return false
        case .task:
            if isViewer {
                return false
            } else {
                return true // 未解決の課題セルのみ編集可能
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            break
        case .task:
            // 左スワイプでセルを削除
            if editingStyle == UITableViewCell.EditingStyle.delete {
                let task = displayTaskArray[indexPath.row]
                let index = taskArray.firstIndex(where: { $0.taskID == task.taskID })
                taskArray[index!].isDisplay = false
                displayTaskArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                resizeScrollView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            switch CellType.allCases[indexPath.row] {
            case .date:
                // datePickerを開く
                closePicker(pickerView)
                pickerView = UIView(frame: datePicker.bounds)
                pickerView.addSubview(datePicker)
                pickerView.addSubview(createToolBar(#selector(datePickerDoneAction), #selector(datePickerCancelAction)))
                openPicker(pickerView)
            case .weather:
                // weatherPickerを開く
                closePicker(pickerView)
                pickerView = UIView(frame: weatherPicker.bounds)
                pickerView.addSubview(weatherPicker)
                pickerView.addSubview(createToolBar(#selector(weatherPickerDoneAction), #selector(weatherPickerCancelAction)))
                openPicker(pickerView)
            }
        case .task:
            tableView.deselectRow(at: indexPath, animated: false)
            break
        }
    }
    
}

extension AddPracticeNoteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch PickerType.allCases[pickerView.tag] {
        case .date:
            return 3
        case .weather:
            return 2 // 天気、気温
        case .task:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch PickerType.allCases[pickerView.tag] {
        case .date:
            return 1
        case .weather:
            if component == 0 {
                return Weather.allCases.count
            } else {
                return temperature.count
            }
        case .task:
            return taskArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch PickerType.allCases[pickerView.tag] {
        case .date:
            return nil
        case .weather:
            if component == 0 {
                return Weather.allCases[row].title
            } else {
                return "\(temperature[row])℃"
            }
        case .task:
            return taskArray[row].title
        }
    }
    
    /// DatePicker初期化
    private func initDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
        datePicker.tag = PickerType.date.rawValue
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.backgroundColor = UIColor.systemGray5
        datePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height + 44)
        if isViewer {
            datePicker.date = realmNote.date
        } else {
            datePicker.date = Date()
        }
    }
    
    @objc func datePickerDoneAction() {
        // 選択したIndexを取得して閉じる
        selectedDate = datePicker.date
        closePicker(pickerView)
        dateTableView.reloadData()
        
        if isViewer {
            // 日付を更新
            let realmManager = RealmManager()
            realmManager.updateNoteDate(noteID: realmNote.noteID, date: selectedDate)
        }
    }
    
    @objc func datePickerCancelAction() {
        // Indexを元に戻して閉じる
        datePicker.date = selectedDate
        closePicker(pickerView)
        dateTableView.deselectRow(at: dateTableView.indexPathForSelectedRow!, animated: true)
    }
    
    /// WeatherPicker初期化
    private func initWeatherPicker() {
        weatherPicker.delegate = self
        weatherPicker.dataSource = self
        weatherPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: weatherPicker.bounds.size.height + 44)
        weatherPicker.backgroundColor = UIColor.systemGray5
        weatherPicker.tag = PickerType.weather.rawValue
        
        if isViewer {
            weatherPicker.selectRow(realmNote.weather ,inComponent: 0, animated: true)
            weatherPicker.selectRow(realmNote.temperature + 40, inComponent: 1, animated: true)
        } else {
            weatherPicker.selectRow(60, inComponent: 1, animated: true)
        }
        selectedWeather[TITLE_WEATHER] = weatherPicker.selectedRow(inComponent: 0)
        selectedWeather[TITLE_TEMPERATURE] = weatherPicker.selectedRow(inComponent: 1)
    }
    
    @objc func weatherPickerDoneAction() {
        // 選択したIndexを取得して閉じる
        selectedWeather[TITLE_WEATHER] = weatherPicker.selectedRow(inComponent: 0)
        selectedWeather[TITLE_TEMPERATURE] = weatherPicker.selectedRow(inComponent: 1)
        closePicker(pickerView)
        dateTableView.reloadData()
        
        if isViewer {
            // 天気と気温を更新
            let realmManager = RealmManager()
            realmManager.updateNoteWeather(noteID: realmNote.noteID, weather: Weather.allCases[selectedWeather[TITLE_WEATHER]!].rawValue)
            realmManager.updateNoteWeather(noteID: realmNote.noteID, weather: temperature[selectedWeather[TITLE_TEMPERATURE]!])
        }
    }
    
    @objc func weatherPickerCancelAction() {
        // Indexを元に戻して閉じる
        weatherPicker.selectRow(selectedWeather[TITLE_WEATHER]!, inComponent: 0, animated: false)
        weatherPicker.selectRow(selectedWeather[TITLE_TEMPERATURE]!, inComponent: 1, animated: false)
        closePicker(pickerView)
        dateTableView.deselectRow(at: dateTableView.indexPathForSelectedRow!, animated: true)
    }
    
    /// TaskPicker初期化
    private func initTaskPicker() {
        taskPicker.delegate = self
        taskPicker.dataSource = self
        taskPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: taskPicker.bounds.size.height + 44)
        taskPicker.backgroundColor = UIColor.systemGray5
        taskPicker.tag = PickerType.task.rawValue
    }
    
    @objc func taskPickerDoneAction() {
        let index = taskPicker.selectedRow(inComponent: 0)
        let selectedTask = taskArray[index]
        
        // 非表示の課題が選択された場合のみtaskTableに追加
        if selectedTask.isDisplay {
            showErrorAlert(message: TASK_EXIST_ERROR)
        } else {
            taskArray[index].isDisplay = true
            displayTaskArray.append(taskArray[index])
            taskTableView.insertRows(at: [IndexPath(row: displayTaskArray.count - 1, section: 0)], with: .right)
            resizeScrollView()
        }
        closePicker(pickerView)
    }
    
    @objc func taskPickerCancelAction() {
        closePicker(pickerView)
    }
    
}

extension AddPracticeNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if !isViewer {
            return
        }
        
        // 差分がなければ何もしない
        let realmManager = RealmManager()
        switch TextViewType.allCases[textView.tag] {
        case .condition:
            if textView.text! != realmNote.condition {
                realmManager.updateNoteCondition(noteID: realmNote.noteID, condition: textView.text!)
            }
        case .purpose:
            if textView.text! != realmNote.purpose {
                realmManager.updateNotePurpose(noteID: realmNote.noteID, purpose: textView.text!)
            }
        case .detail:
            if textView.text! != realmNote.detail {
                realmManager.updateNoteDetail(noteID: realmNote.noteID, detail: textView.text!)
            }
        case .reflection:
            if textView.text! != realmNote.reflection {
                realmManager.updateNoteReflection(noteID: realmNote.noteID, reflection: textView.text!)
            }
        }
    }
    
}
