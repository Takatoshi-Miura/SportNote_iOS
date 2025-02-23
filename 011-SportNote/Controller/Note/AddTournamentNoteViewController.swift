//
//  TournamentNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/18.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol AddTournamentNoteViewControllerDelegate: AnyObject {
    // モーダルを閉じる時の処理
    func addTournamentNoteVCDismiss(_ viewController: UIViewController)
    // ノート追加時の処理
    func addTournamentNoteVCAddNote(_ viewController: UIViewController)
    // ノート削除時の処理
    func addTournamentNoteVCDeleteNote()
}

class AddTournamentNoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var naviBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var consciousnessLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var reflectionLabel: UILabel!
    @IBOutlet weak var conditionTextView: UITextView!
    @IBOutlet weak var targetTextView: UITextView!
    @IBOutlet weak var consciousnessTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var scrollViewTop: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var editingTextView: UITextView?
    private var lastOffsetY: CGFloat = 0.0
    
    var delegate: AddTournamentNoteViewControllerDelegate?
    var isViewer = false
    var realmNote = Note()
    
    private var pickerView = UIView()
    private var datePicker = UIDatePicker()
    private var weatherPicker = UIPickerView()
    private let temperature:[Int] = (-40...40).map { $0 }
    private var selectedDate = Date()
    private var selectedWeather: [String : Int] = [TITLE_WEATHER: 0 ,TITLE_TEMPERATURE: 0]
    
    private enum CellType: Int, CaseIterable {
        case date
        case weather
    }
    
    private enum TextViewType: Int, CaseIterable {
        case condition
        case target
        case consciousness
        case result
        case reflection
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initNavigationBar()
        initTableView()
        initPicker()
        initNotification()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        datePicker.frame.size.width = self.view.bounds.size.width
        weatherPicker.frame.size.width = self.view.bounds.size.width
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isViewer {
            // Firebaseに送信
            if Network.isOnline() {
                let firebaseManager = FirebaseManager()
                firebaseManager.updateNote(note: realmNote)
            }
        }
    }
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_ADD_TOURNAMENT_NOTE
        conditionLabel.text = TITLE_CONDITION
        targetLabel.text = TITLE_TARGET
        consciousnessLabel.text = TITLE_CONSCIOUSNESS
        resultLabel.text = TITLE_RESULT
        reflectionLabel.text = TITLE_REFLECTION
        
        initTextView(textView: conditionTextView, doneAction: #selector(tapOkButton(_:)))
        initTextView(textView: targetTextView, doneAction: #selector(tapOkButton(_:)))
        initTextView(textView: consciousnessTextView, doneAction: #selector(tapOkButton(_:)))
        initTextView(textView: resultTextView, doneAction: #selector(tapOkButton(_:)))
        initTextView(textView: reflectionTextView, doneAction: #selector(tapOkButton(_:)))
        
        conditionTextView.tag = TextViewType.condition.rawValue
        targetTextView.tag = TextViewType.target.rawValue
        consciousnessTextView.tag = TextViewType.consciousness.rawValue
        resultTextView.tag = TextViewType.result.rawValue
        reflectionTextView.tag = TextViewType.reflection.rawValue
        
        if isViewer {
            naviBar.isHidden = true
            scrollViewTop.constant = -44
            // ノート内容を反映
            conditionTextView.text = realmNote.condition
            targetTextView.text = realmNote.target
            consciousnessTextView.text = realmNote.consciousness
            resultTextView.text = realmNote.result
            reflectionTextView.text = realmNote.reflection
        }
    }
    
    /// キーボード、Pickerを隠す
    @objc func tapOkButton(_ sender: UIButton){
        self.view.endEditing(true)
        closePicker(pickerView)
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    
    // MARK: - Action
    
    /// ノートを削除
    @objc func deleteNote() {
        showDeleteAlert(title: TITLE_DELETE_NOTE, message: MESSAGE_DELETE_NOTE, OKAction: {
            let realmManager = RealmManager()
            realmManager.updateNoteIsDeleted(noteID: self.realmNote.noteID)
            self.delegate?.addTournamentNoteVCDeleteNote()
        })
    }
    
    /// 保存ボタンタップ時の処理
    @IBAction func tapSaveButton(_ sender: Any) {
        // 大会ノートデータを作成＆保存
        let realmManager = RealmManager()
        let tournamentNote = createTournamentNote()
        if !realmManager.createRealm(object: tournamentNote) {
            showErrorAlert(message: ERROR_MESSAGE_NOTE_CREATE_FAILED)
            return
        }
        
        // Firebaseに送信
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.saveNote(note: tournamentNote, completion: {})
        }
        
        self.delegate?.addTournamentNoteVCAddNote(self)
    }
    
    /// 入力内容からNoteデータを作成
    /// - Returns: Note
    private func createTournamentNote() -> Note {
        let tournamentNote = Note()
        tournamentNote.noteType = NoteType.tournament.rawValue
        tournamentNote.date = selectedDate
        tournamentNote.weather = Weather.allCases[selectedWeather[TITLE_WEATHER]!].rawValue
        tournamentNote.temperature = temperature[selectedWeather[TITLE_TEMPERATURE]!]
        tournamentNote.condition = conditionTextView.text
        tournamentNote.target = targetTextView.text
        tournamentNote.consciousness = consciousnessTextView.text
        tournamentNote.result = resultTextView.text
        tournamentNote.reflection = reflectionTextView.text
        return tournamentNote
    }
    
    /// キャンセルボタンタップ時の処理
    @IBAction func tapCancelButton(_ sender: Any) {
        if conditionTextView.text.isEmpty &&
            targetTextView.text.isEmpty &&
            consciousnessTextView.text.isEmpty &&
            resultTextView.text.isEmpty &&
            reflectionTextView.text.isEmpty
        {
            self.delegate?.addTournamentNoteVCDismiss(self)
        } else {
            showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                self.delegate?.addTournamentNoteVCDismiss(self)
            })
        }
    }
    
}

extension AddTournamentNoteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toolBarHeight: CGFloat = 44
        let safeAreaBottom: CGFloat = view.safeAreaInsets.bottom
        self.view.endEditing(true)
        switch CellType.allCases[indexPath.row] {
        case .date:
            closePicker(pickerView)
            pickerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height + toolBarHeight + safeAreaBottom))
            pickerView.addSubview(datePicker)
            pickerView.addSubview(createToolBar(#selector(datePickerDoneAction), #selector(datePickerCancelAction)))
            openPicker(pickerView)
        case .weather:
            closePicker(pickerView)
            pickerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: weatherPicker.bounds.size.height + toolBarHeight + safeAreaBottom))
            pickerView.addSubview(weatherPicker)
            pickerView.addSubview(createToolBar(#selector(weatherPickerDoneAction), #selector(weatherPickerCancelAction)))
            openPicker(pickerView)
        }
    }
    
}

extension AddTournamentNoteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 天気、気温
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return Weather.allCases.count
        } else {
            return temperature.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return Weather.allCases[row].title
        } else {
            return "\(temperature[row])℃"
        }
    }
    
    /// Picker初期化
    private func initPicker() {
        initDatePicker()
        initWeatherPicker()
    }
    
    /// DatePicker初期化
    private func initDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.backgroundColor = UIColor.systemGray5
        datePicker.frame = CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height)
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
        tableView.reloadData()
        
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
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
    /// Picker初期化
    private func initWeatherPicker() {
        weatherPicker.delegate = self
        weatherPicker.dataSource = self
        weatherPicker.frame = CGRect(x: 0, y: 44, width: UIScreen.main.bounds.size.width, height: weatherPicker.bounds.size.height)
        weatherPicker.backgroundColor = UIColor.systemGray5
        
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
        tableView.reloadData()
        
        if isViewer {
            // 天気と気温を更新
            let realmManager = RealmManager()
            realmManager.updateNoteWeather(noteID: realmNote.noteID, weather: Weather.allCases[selectedWeather[TITLE_WEATHER]!].rawValue)
            realmManager.updateNoteTemperature(noteID: realmNote.noteID, temperature: temperature[selectedWeather[TITLE_TEMPERATURE]!])
        }
    }
    
    @objc func weatherPickerCancelAction() {
        // Indexを元に戻して閉じる
        weatherPicker.selectRow(selectedWeather[TITLE_WEATHER]!, inComponent: 0, animated: false)
        weatherPicker.selectRow(selectedWeather[TITLE_TEMPERATURE]!, inComponent: 1, animated: false)
        closePicker(pickerView)
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
}

extension AddTournamentNoteViewController {
    
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

extension AddTournamentNoteViewController: UITextViewDelegate {
    
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
            if textView.text! != realmNote.condition {
                realmManager.updateNoteCondition(noteID: realmNote.noteID, condition: textView.text!)
            }
        case .target:
            if textView.text! != realmNote.target {
                realmManager.updateNoteTarget(noteID: realmNote.noteID, target: textView.text!)
            }
        case .consciousness:
            if textView.text! != realmNote.consciousness {
                realmManager.updateNoteConsciousness(noteID: realmNote.noteID, consciousness: textView.text!)
            }
        case .result:
            if textView.text! != realmNote.result {
                realmManager.updateNoteResult(noteID: realmNote.noteID, result: textView.text!)
            }
        case .reflection:
            if textView.text! != realmNote.reflection {
                realmManager.updateNoteReflection(noteID: realmNote.noteID, reflection: textView.text!)
            }
        }
    }
    
}
