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
