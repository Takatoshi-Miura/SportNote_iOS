//
//  NoteDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/11.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class NoteDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // タイトル文字列の設定
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.text = "\(noteData.getNavigationTitle())\n\(noteData.getNoteType())"
        self.navigationItem.titleView = label
        
        // デリゲートとデータソースの指定
        tableView.delegate   = self
        tableView.dataSource = self
        
        // TaskTableViewCellを登録
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskTableViewCell")
        
        // データを表示
        printNoteData(noteData)
        
        // テーブルを再読み込み
        self.tableView?.reloadData()
    }
    
    
    
    //MARK:- 変数の宣言
    
    var noteData = NoteData()
    
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var physicalConditionTextView: UITextView!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 編集ボタンの処理
    @IBAction func editButton(_ sender: Any) {
        // 練習記録追加画面を取得
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddPracticeNoteViewController") as! AddPracticeNoteViewController
        
        // ノートデータの受け渡し
        nextView.noteData = self.noteData
        nextView.previousControllerName = "NoteDetailViewController"
        
        // 画面遷移
        self.present(nextView, animated: true, completion: nil)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.noteData.getTaskTitle().count   // セルの個数(取り組んだ課題の数)を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as! TaskTableViewCell
        cell.printTaskData(self.noteData,indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200  // セルの高さ設定
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
