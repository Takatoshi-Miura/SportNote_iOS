//
//  UpdatePracticeNoteContentViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/11.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class UpdatePracticeNoteContentViewController: AddPracticeNoteContentViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 時間待ち(ノートデータ受け取り)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            // 初期値の設定(受け取ったnoteDataに値に設定)
            self.temperatureIndex = self.noteData.getTemperature() + 40
            self.weatherPicker.selectRow(self.temperatureIndex, inComponent: 1, animated: true)
            if self.noteData.getWeather() == "くもり" {
                self.weatherIndex = 1
            } else if self.noteData.getWeather() == "雨" {
                self.weatherIndex = 2
            }
            self.weatherPicker.selectRow(self.weatherIndex ,inComponent: 0, animated: true)
            
            // テキストビューに値をセット
            self.physicalConditionTextView.text = self.noteData.getPhysicalCondition()
            self.purposeTextView.text = self.noteData.getPurpose()
            self.detailTextView.text = self.noteData.getDetail()
            self.reflectionTextView.text = self.noteData.getReflection()
            
            // テーブルビューを更新
            self.tableView.reloadData()
        }
    }
    
    
    
    //MARK:- 変数の宣言
    
    // データ格納用
    var noteData = NoteData()
    
    
    //MARK:- UIの設定
    
    // 保存ボタンの処理
    override func saveButton() {
        // Pickerの選択項目をセット
        noteData.setYear(year)
        noteData.setMonth(month)
        noteData.setDate(date)
        noteData.setDay(day)
        noteData.setWeather(weather[weatherIndex])
        noteData.setTemperature(temperature[temperatureIndex])
        
        // 入力テキストをセット
        noteData.setPhysicalCondition(physicalConditionTextView.text!)
        noteData.setPurpose(purposeTextView.text!)
        noteData.setDetail(detailTextView.text!)
        noteData.setReflection(reflectionTextView.text!)
        
        // データを更新
        noteData.updateNoteData()
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return 2    // 日付セル,天候セルの2つ
        } else {
            return taskDataArray.count     // 未解決の課題の数
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            if indexPath.row == 0 {
                // 0行目のセルは日付セルを返却
                cell.textLabel!.text = "日付"
                cell.detailTextLabel!.text = selectedDate
                cell.detailTextLabel?.textColor = UIColor.systemGray
                return cell
            } else {
                // 1行目のセルは天候セルを返却
                cell.textLabel!.text = "天候"
                cell.detailTextLabel!.text = "\(weather[weatherIndex]) \(temperature[temperatureIndex])℃"
                cell.detailTextLabel?.textColor = UIColor.systemGray
                return cell
            }
        } else {
            // 未解決の課題セルを返却
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskMeasuresTableViewCell", for: indexPath) as! TaskMeasuresTableViewCell
            //cell.printTaskData(taskDataArray[indexPath.row])
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            if indexPath.row == 0 {
                // 日付セルがタップされた時
                // タップしたときの選択色を消去
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                
                // Pickerの初期化
                datePickerInit()
                
                // 下からPickerを呼び出す
                let screenSize = UIScreen.main.bounds.size
                pickerView.frame.origin.y = screenSize.height
                UIView.animate(withDuration: 0.3) {
                    self.pickerView.frame.origin.y = screenSize.height - self.pickerView.bounds.size.height - 60
                }
            } else {
                // 天候セルがタップされた時
                // タップしたときの選択色を消去
                tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                
                // Pickerの初期化
                weatherPickerInit()
                
                // 下からPickerを呼び出す
                let screenSize = UIScreen.main.bounds.size
                pickerView.frame.origin.y = screenSize.height
                UIView.animate(withDuration: 0.3) {
                    self.pickerView.frame.origin.y = screenSize.height - self.pickerView.bounds.size.height - 60
                }
            }
        } else {
            // 未解決の課題セルをタップしたときの処理
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }

    

}
