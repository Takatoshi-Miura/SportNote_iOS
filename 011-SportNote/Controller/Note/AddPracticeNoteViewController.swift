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
    var delegate: AddPracticeNoteViewControllerDelegate?
    var isViewer = false
    var realmNote = Note()
    
    private var pickerView = UIView()
    private var datePicker = UIDatePicker()
    private var weatherPicker = UIPickerView()
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
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initTableView()
        initDatePicker()
        initWeatherPicker()
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
            // TODO: 更新処理
            
            // Firebaseに送信
            if Network.isOnline() {
                let firebaseManager = FirebaseManager()
                firebaseManager.updateNote(note: realmNote)
            }
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
        
        initTextView(textView: conditionTextView)
        initTextView(textView: purposeTextView)
        initTextView(textView: detailTextView)
        initTextView(textView: reflectionTextView)
        
        if isViewer {
            naviBar.isHidden = true
            // TODO: レイアウト要修正
            conditionTextView.text = realmNote.condition
            purposeTextView.text = realmNote.purpose
            detailTextView.text = realmNote.detail
            reflectionTextView.text = realmNote.reflection
        }
    }
    
    private func initTableView() {
        dateTableView.tag = TableViewType.date.rawValue
        taskTableView.tag = TableViewType.task.rawValue
        dateTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        taskTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            dateTableView.sectionHeaderTopPadding = 0
            taskTableView.sectionHeaderTopPadding = 0
        }
    }
    
    // MARK: - Action
    @IBAction func tapAddButton(_ sender: Any) {
    }
    
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
        
        // TODO: メモを作成＆保存
        
        let realmManager = RealmManager()
        if !realmManager.createRealm(object: practiceNote) {
            showErrorAlert(message: ERROR_MESSAGE_NOTE_CREATE_FAILED)
            return
        }
        
        // Firebaseに送信
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.saveNote(note: practiceNote, completion: {})
        }
        
        // TODO: NoteVCにアニメーション付きで追加
        self.delegate?.addPracticeNoteVCDismiss(self)
    }
    
}

extension AddPracticeNoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            return 2
        case .task:
            return 0
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
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.detailTextLabel?.textColor = UIColor.systemGray
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        switch TableViewType.allCases[tableView.tag] {
        case .date:
            switch CellType.allCases[indexPath.row] {
            case .date:
                closePicker(pickerView)
                pickerView = UIView(frame: datePicker.bounds)
                pickerView.addSubview(datePicker)
                pickerView.addSubview(createToolBar(#selector(datePickerDoneAction), #selector(datePickerCancelAction)))
                openPicker(pickerView)
            case .weather:
                closePicker(pickerView)
                pickerView = UIView(frame: weatherPicker.bounds)
                pickerView.addSubview(weatherPicker)
                pickerView.addSubview(createToolBar(#selector(weatherPickerDoneAction), #selector(weatherPickerCancelAction)))
                openPicker(pickerView)
            }
        case .task:
            break
        }
    }
    
}

extension AddPracticeNoteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    /// DatePicker初期化
    private func initDatePicker() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
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
    }
    
    @objc func datePickerCancelAction() {
        // Indexを元に戻して閉じる
        datePicker.date = selectedDate
        closePicker(pickerView)
        dateTableView.deselectRow(at: dateTableView.indexPathForSelectedRow!, animated: true)
    }
    
    /// Picker初期化
    private func initWeatherPicker() {
        weatherPicker.delegate = self
        weatherPicker.dataSource = self
        weatherPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: weatherPicker.bounds.size.height + 44)
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
        dateTableView.reloadData()
    }
    
    @objc func weatherPickerCancelAction() {
        // Indexを元に戻して閉じる
        weatherPicker.selectRow(selectedWeather[TITLE_WEATHER]!, inComponent: 0, animated: false)
        weatherPicker.selectRow(selectedWeather[TITLE_TEMPERATURE]!, inComponent: 1, animated: false)
        closePicker(pickerView)
        dateTableView.deselectRow(at: dateTableView.indexPathForSelectedRow!, animated: true)
    }
    
}
