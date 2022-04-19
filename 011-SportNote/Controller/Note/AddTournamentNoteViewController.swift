//
//  TournamentNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/18.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol AddTournamentNoteViewControllerDelegate: AnyObject {
    
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
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var delegate: AddTournamentNoteViewControllerDelegate?
    
    private var pickerView = UIView()
    private var datePicker = UIDatePicker()
    private var weatherPicker = UIPickerView()
    private let temperature:[Int] = (-40...40).map { $0 }
    
    private enum CellType: Int, CaseIterable {
        case date
        case weather
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initTableView()
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
        naviItem.title = TITLE_ADD_TASK
        conditionLabel.text = TITLE_CONDITION
        targetLabel.text = TITLE_TARGET
        consciousnessLabel.text = TITLE_CONSCIOUSNESS
        resultLabel.text = TITLE_RESULT
        reflectionLabel.text = TITLE_REFLECTION
        
        conditionTextView.text = ""
        targetTextView.text = ""
        consciousnessTextView.text = ""
        resultTextView.text = ""
        reflectionTextView.text = ""
        
        addBorder(textView: conditionTextView)
        addBorder(textView: targetTextView)
        addBorder(textView: consciousnessTextView)
        addBorder(textView: resultTextView)
        addBorder(textView: reflectionTextView)
        
        saveButton.setTitle(TITLE_SAVE, for: .normal)
        cancelButton.setTitle(TITLE_CANCEL, for: .normal)
    }
    
    /// TextViewの枠線付与
    private func addBorder(textView: UITextView) {
        textView.layer.borderColor = UIColor.systemGray6.cgColor
        textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 5.0
        textView.layer.masksToBounds = true
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
    }
    
    /// キャンセルボタンタップ時の処理
    @IBAction func tapCancelButton(_ sender: Any) {
    }
    
    
}

extension AddTournamentNoteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.detailTextLabel?.textColor = UIColor.systemGray
        
        switch CellType.allCases[indexPath.row] {
        case .date:
            cell.textLabel!.text = "日付"
            cell.detailTextLabel!.text = ""
        case .weather:
            cell.textLabel!.text = "天気"
            cell.detailTextLabel!.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch CellType.allCases[indexPath.row] {
        case .date:
            closePicker(pickerView)
            pickerView = UIView(frame: datePicker.bounds)
            pickerView.addSubview(datePicker)
            pickerView.addSubview(createToolBar(#selector(doneAction), #selector(cancelAction)))
            openPicker(pickerView)
        case .weather:
            closePicker(pickerView)
            pickerView = UIView(frame: weatherPicker.bounds)
            pickerView.addSubview(weatherPicker)
            pickerView.addSubview(createToolBar(#selector(doneAction), #selector(cancelAction)))
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
            return String(temperature[row])
        }
    }
    
    /// Picker初期化
    private func initWeatherPicker() {
        weatherPicker.delegate = self
        weatherPicker.dataSource = self
        weatherPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: weatherPicker.bounds.size.height + 44)
        weatherPicker.backgroundColor = UIColor.systemGray5
    }
    
    @objc func doneAction() {
        // 選択したIndexを取得して閉じる
//        pickerIndex = weatherPicker.selectedRow(inComponent: 0)
//        pickerIndex = weatherPicker.selectedRow(inComponent: 1)
        closePicker(pickerView)
//        colorButton.backgroundColor = Color.allCases[realmGroupArray[pickerIndex].color].color
//        colorButton.setTitle(realmGroupArray[pickerIndex].title, for: .normal)
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
//        weatherPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
        closePicker(pickerView)
    }
    
}

extension AddTournamentNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
    }
    
}
