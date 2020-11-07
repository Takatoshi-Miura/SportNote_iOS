//
//  NoteViewCell.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/11/04.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class NoteViewCell: UITableViewCell {

    //MARK:- UIの設定
    
    @IBOutlet weak var noteTypeImageView: UIImageView!
    @IBOutlet weak var noteDateLabel: UILabel!
    @IBOutlet weak var noteDetailLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    //MARK:- その他のメソッド
    
    // ラベルに表示するメソッド
    func printNoteData(_ noteData:NoteData) {
        // ノートタイプアイコン
        if noteData.getNoteType() == "練習記録" {
            noteTypeImageView.image = UIImage(named: "practice")
        } else {
            noteTypeImageView.image = UIImage(named: "cup")
        }
        
        // 日付
        noteDateLabel.text = noteData.getCellTitle()
        
        // 内容
        noteDetailLabel.numberOfLines = 0
        if noteData.getNoteType() == "練習記録" {
            noteDetailLabel.text = noteData.getDetail()
        } else {
            noteDetailLabel.text = noteData.getResult()
        }
        
        // 天気アイコン
        switch noteData.getWeather() {
        case "晴れ":
            weatherImageView.image = UIImage(named: "sunny")
        case "くもり":
            weatherImageView.image = UIImage(named: "cloudy")
        case "雨":
            weatherImageView.image = UIImage(named: "rainy")
        default:
            break
        }
        
        // 気温
        temperatureLabel.text = "\(noteData.getTemperature())℃"
    }
}
