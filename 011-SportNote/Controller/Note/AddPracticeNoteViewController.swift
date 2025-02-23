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
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var editingTextView: UITextView?
    private var lastOffsetY: CGFloat = 0.0
    
    private var taskArray = [TaskForAddNote]()
    private var displayTaskArray = [TaskForAddNote]()
    private var realmMemoArray = [Memo]()
    var delegate: AddPracticeNoteViewControllerDelegate?
    var isViewer = false
    var note = Note()
    
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
        initNavigationBar()
        initTableView()
        initPicker()
        initTaskData()
        resizeScrollView()
        initNotification()
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
            firebaseManager.updateNote(note: note)
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
            conditionTextView.text = note.condition
            purposeTextView.text = note.purpose
            detailTextView.text = note.detail
            reflectionTextView.text = note.reflection
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
    
    /// NavigationBar初期化
    private func initNavigationBar() {
        if !isViewer {
            return
        }
        self.title = TITLE_NOTE_DETAIL
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        deleteButton.tintColor = UIColor.red
        navigationItems.append(deleteButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    /// TableView初期化
    private func initTableView() {
        dateTableView.tag = TableViewType.date.rawValue
        taskTableView.tag = TableViewType.task.rawValue
        dateTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        taskTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
            displayTaskArray = realmManager.getTaskArrayForAddNoteView(noteID: note.noteID)
            realmMemoArray = realmManager.getMemo(noteID: note.noteID)
            if displayTaskArray.isEmpty {
                taskTableView.separatorStyle = .none
            }
        } else {
            // 未解決の課題を取得
            displayTaskArray = realmManager.getTaskArrayForAddNoteView()
        }
    }
    
    /// スクロール領域を調整
    private func resizeScrollView() {
        var tableHeight = CGFloat(0)
        if isViewer && displayTaskArray.isEmpty {
            tableHeight = CGFloat(44)
        } else {
            tableHeight = CGFloat(displayTaskArray.count * 200)
        }
        taskTableViewHeight.constant = tableHeight
        scrollViewHeight.constant = CGFloat(1000 + tableHeight)
    }
    
    
    // MARK: - Action
    
    /// ノートを削除
    @objc func deleteNote() {
        showDeleteAlert(title: TITLE_DELETE_NOTE, message: MESSAGE_DELETE_NOTE, OKAction: {
            let realmManager = RealmManager()
            realmManager.updateNoteIsDeleted(noteID: self.note.noteID)
            realmManager.updateMemoIsDeleted(noteID: self.note.noteID)
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
        let toolBarHeight: CGFloat = 44
        let safeAreaBottom: CGFloat = view.safeAreaInsets.bottom
        closePicker(pickerView)
        pickerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: taskPicker.bounds.size.height + toolBarHeight + safeAreaBottom))
        pickerView.addSubview(taskPicker)
        pickerView.addSubview(createToolBar(#selector(taskPickerDoneAction), #selector(taskPickerCancelAction)))
        openPicker(pickerView, isModal: !isViewer)
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
        let realmManager = RealmManager()
        let practiceNote = createPracticeNote()
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
    
    /// 入力内容からNoteデータを作成
    /// - Returns: Note
    private func createPracticeNote() -> Note {
        let practiceNote = Note()
        practiceNote.noteType = NoteType.practice.rawValue
        practiceNote.date = selectedDate
        practiceNote.weather = Weather.allCases[selectedWeather[TITLE_WEATHER]!].rawValue
        practiceNote.temperature = temperature[selectedWeather[TITLE_TEMPERATURE]!]
        practiceNote.condition = conditionTextView.text
        practiceNote.purpose = purposeTextView.text
        practiceNote.detail = detailTextView.text
        practiceNote.reflection = reflectionTextView.text
        return practiceNote
    }
    
}

extension AddPracticeNoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            return 2
        case .task:
            if isViewer && displayTaskArray.isEmpty {
                return 1
            } else {
                return displayTaskArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            return 44
        case .task:
            if isViewer && displayTaskArray.isEmpty {
                return 44
            } else {
                return 200
            }
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
            if isViewer && displayTaskArray.isEmpty {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel?.text = MESSAGE_DONE_TASK_EMPTY
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCellForAddNote", for: indexPath) as! TaskCellForAddNote
                cell.printInfo(task: displayTaskArray[indexPath.row])
                if isViewer {
                    cell.printMemo(memo: realmMemoArray[indexPath.row])
                }
                return cell
            }
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
        let toolBarHeight: CGFloat = 44
        let safeAreaBottom: CGFloat = view.safeAreaInsets.bottom
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            switch CellType.allCases[indexPath.row] {
            case .date:
                // datePickerを開く
                closePicker(pickerView)
                pickerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height + toolBarHeight + safeAreaBottom))
                pickerView.addSubview(datePicker)
                pickerView.addSubview(createToolBar(#selector(datePickerDoneAction), #selector(datePickerCancelAction)))
                openPicker(pickerView, isModal: !isViewer)
            case .weather:
                // weatherPickerを開く
                closePicker(pickerView)
                pickerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: weatherPicker.bounds.size.height + toolBarHeight + safeAreaBottom))
                pickerView.addSubview(weatherPicker)
                pickerView.addSubview(createToolBar(#selector(weatherPickerDoneAction), #selector(weatherPickerCancelAction)))
                openPicker(pickerView, isModal: !isViewer)
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
    
    /// Picker初期化
    private func initPicker() {
        initDatePicker()
        initWeatherPicker()
        initTaskPicker()
    }
    
    /// DatePicker初期化
    private func initDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
        datePicker.tag = PickerType.date.rawValue
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.backgroundColor = UIColor.systemGray5
        datePicker.frame = CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height)
        if isViewer {
            datePicker.date = note.date
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
            realmManager.updateNoteDate(noteID: note.noteID, date: selectedDate)
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
        weatherPicker.frame = CGRect(x: 0, y: 44, width: self.view.bounds.size.width, height: weatherPicker.bounds.size.height)
        weatherPicker.backgroundColor = UIColor.systemGray5
        weatherPicker.tag = PickerType.weather.rawValue
        
        if isViewer {
            weatherPicker.selectRow(note.weather , inComponent: 0, animated: true)
            weatherPicker.selectRow(note.temperature + 40, inComponent: 1, animated: true)
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
            realmManager.updateNoteWeather(noteID: note.noteID, weather: Weather.allCases[selectedWeather[TITLE_WEATHER]!].rawValue)
            realmManager.updateNoteTemperature(noteID: note.noteID, temperature:  temperature[selectedWeather[TITLE_TEMPERATURE]!])
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
        taskPicker.frame = CGRect(x: 0, y: 44, width: self.view.bounds.size.width, height: taskPicker.bounds.size.height)
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

extension AddPracticeNoteViewController {
    
    /// Notification初期化
    private func initNotification() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// キーボードのサイズ変化時のイベントハンドラー
    /// テキストフィールドが隠れた場合は自動スクロール
    /// - Parameter notification: Notification
    @objc private func keyboardChangeFrame(_ notification: Notification) {
        // キーボード退場でも同じイベントが発生するため、編集中のTextViewがnilの時は処理を中断
        guard let textView = editingTextView else {
            return
        }
        
        // 重なり具合の比較を容易にするため、TextViewのframeをキーボードと同じウィンドウの座標系にする
        guard let textViewFrame = view.window?.convert(textView.frame, from: textView.superview) else {
            return
        }
        
        // 編集中のTextViewがキーボードと重なっている場合、重なっている分だけスクロール
        // 重なり = (テキストフィールドの下端 + 余白) - キーボードの上端
        let userInfo = notification.userInfo
        let keyboardFrame = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let spaceBetweenTextFieldAndKeyboard: CGFloat = 8
        var overlap = (textViewFrame.maxY + spaceBetweenTextFieldAndKeyboard) - keyboardFrame.minY
        if overlap > 0 {
            overlap = overlap + scrollView.contentOffset.y
            scrollView.setContentOffset(CGPoint(x: 0, y: overlap), animated: true)
        }
    }
    
    /// キーボード登場時のイベントハンドラー
    @objc private func keyboardWillShow(_ notification: Notification) {
        lastOffsetY = scrollView.contentOffset.y
    }
    
    /// キーボード退場時のイベントハンドラー
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.setContentOffset(CGPoint(x: 0, y: lastOffsetY), animated: true)
    }
    
}

extension AddPracticeNoteViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 編集中のTextViewに設定
        editingTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // 編集中のTextViewをクリア
        editingTextView = nil
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !isViewer {
            return
        }
        
        // 差分がなければ何もしない
        let realmManager = RealmManager()
        switch TextViewType.allCases[textView.tag] {
        case .condition:
            if textView.text! != note.condition {
                realmManager.updateNoteCondition(noteID: note.noteID, condition: textView.text!)
            }
        case .purpose:
            if textView.text! != note.purpose {
                realmManager.updateNotePurpose(noteID: note.noteID, purpose: textView.text!)
            }
        case .detail:
            if textView.text! != note.detail {
                realmManager.updateNoteDetail(noteID: note.noteID, detail: textView.text!)
            }
        case .reflection:
            if textView.text! != note.reflection {
                realmManager.updateNoteReflection(noteID: note.noteID, reflection: textView.text!)
            }
        }
    }
    
}
