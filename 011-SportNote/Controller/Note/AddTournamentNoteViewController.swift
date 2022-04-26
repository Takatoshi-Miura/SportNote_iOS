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
}

class AddTournamentNoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
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
    var delegate: AddTournamentNoteViewControllerDelegate?
    
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
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_ADD_TOURNAMENT_NOTE
        conditionLabel.text = TITLE_CONDITION
        targetLabel.text = TITLE_TARGET
        consciousnessLabel.text = TITLE_CONSCIOUSNESS
        resultLabel.text = TITLE_RESULT
        reflectionLabel.text = TITLE_REFLECTION
        
        initTextView(textView: conditionTextView)
        initTextView(textView: targetTextView)
        initTextView(textView: consciousnessTextView)
        initTextView(textView: resultTextView)
        initTextView(textView: reflectionTextView)
    }
    
    /// TextView初期化
    private func initTextView(textView: UITextView) {
        textView.text = ""
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.layer.masksToBounds = true
        textView.inputAccessoryView = createToolBar(#selector(tapOkButton(_:)), #selector(tapOkButton(_:)))
    }
    
    /// キーボード、Pickerを隠す
    @objc func tapOkButton(_ sender: UIButton){
        self.view.endEditing(true)
        closePicker(pickerView)
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: true)
        }
    }
    
    private func initTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    
    // MARK: - Action
    
    /// 保存ボタンタップ時の処理
    @IBAction func tapSaveButton(_ sender: Any) {
        // 大会ノートデータを作成＆保存
        let realmManager = RealmManager()
        let tournamentNote = TournamentNote()
        tournamentNote.date = selectedDate
        tournamentNote.weather = Weather.allCases[selectedWeather[TITLE_WEATHER]!].rawValue
        tournamentNote.temperature = selectedWeather[TITLE_TEMPERATURE]!
        tournamentNote.condition = conditionTextView.text
        tournamentNote.target = targetTextView.text
        tournamentNote.consciousness = consciousnessTextView.text
        tournamentNote.result = resultTextView.text
        tournamentNote.reflection = reflectionTextView.text
        
        if !realmManager.createRealm(object: tournamentNote) {
            showErrorAlert(message: ERROR_MESSAGE_NOTE_CREATE_FAILED)
            return
        }
        
        // Firebaseに送信
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.saveTournamentNote(tournamentNote: tournamentNote, completion: {})
        }
        
        // TODO: NoteVCにアニメーション付きで追加
        self.delegate?.addTournamentNoteVCDismiss(self)
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
        self.view.endEditing(true)
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
    
    /// DatePicker初期化
    private func initDatePicker() {
        datePicker = UIDatePicker()
        datePicker.date = Date()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ja")
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.backgroundColor = UIColor.systemGray5
        datePicker.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: datePicker.bounds.size.height + 44)
    }
    
    @objc func datePickerDoneAction() {
        // 選択したIndexを取得して閉じる
        selectedDate = datePicker.date
        closePicker(pickerView)
        tableView.reloadData()
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
        weatherPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: weatherPicker.bounds.size.height + 44)
        weatherPicker.backgroundColor = UIColor.systemGray5
        weatherPicker.selectRow(60, inComponent: 1, animated: true)
        selectedWeather[TITLE_WEATHER] = weatherPicker.selectedRow(inComponent: 0)
        selectedWeather[TITLE_TEMPERATURE] = weatherPicker.selectedRow(inComponent: 1)
    }
    
    @objc func weatherPickerDoneAction() {
        // 選択したIndexを取得して閉じる
        selectedWeather[TITLE_WEATHER] = weatherPicker.selectedRow(inComponent: 0)
        selectedWeather[TITLE_TEMPERATURE] = weatherPicker.selectedRow(inComponent: 1)
        closePicker(pickerView)
        tableView.reloadData()
    }
    
    @objc func weatherPickerCancelAction() {
        // Indexを元に戻して閉じる
        weatherPicker.selectRow(selectedWeather[TITLE_WEATHER]!, inComponent: 0, animated: false)
        weatherPicker.selectRow(selectedWeather[TITLE_TEMPERATURE]!, inComponent: 1, animated: false)
        closePicker(pickerView)
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
    }
    
}

extension AddTournamentNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
    }
    
}
