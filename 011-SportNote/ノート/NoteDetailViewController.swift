//
//  NoteDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/11.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class NoteDetailViewController: UIViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // タイトル文字列の設定
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        if noteData.getNoteType() == "練習記録" {
            label.textColor = .systemGreen
        } else {
            label.textColor = .systemRed
        }
        label.text = "\(noteData.getNavigationTitle())\n\(noteData.getNoteType())"
        self.navigationItem.titleView = label
        
        // データを表示
        printNoteData(noteData)
    }
    
    
    
    //MARK:- 変数の宣言
    
    var noteData = NoteData()
    
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var physicalConditionTextView: UITextView!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    
    // 編集ボタンの処理
    @IBAction func editButton(_ sender: Any) {
        if noteData.getNoteType() == "練習記録" {
            // 練習記録追加画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "UpdatePracticeNoteViewController") as! UpdatePracticeNoteViewController
            nextView.noteData = self.noteData
            self.present(nextView, animated: true, completion: nil)
        } else if noteData.getNoteType() == "大会記録" {
            // 大会記録追加画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "UpdateCompetitionNoteViewController") as! UpdateCompetitionNoteViewController
            nextView.noteData = self.noteData
            self.present(nextView, animated: true, completion: nil)
        }
    }
    
    
    
    //MARK:- 画面遷移
    
    // NoteDetailViewControllerに戻ったときの処理
    @IBAction func goToNoteDetailViewController(_segue:UIStoryboardSegue) {
    }
    
    
    
    //MARK:- その他のメソッド
    
    // テキストビューにnoteDataを表示するメソッド
    func printNoteData(_ noteData:NoteData) {
        // テキストビューに表示
        physicalConditionTextView.text = noteData.getPhysicalCondition()
        purposeTextView.text = noteData.getPurpose()
        detailTextView.text = noteData.getDetail()
        reflectionTextView.text = noteData.getReflection()
    }
    
    
}
