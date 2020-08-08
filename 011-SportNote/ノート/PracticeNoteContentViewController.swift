//
//  PracticeNoteContentViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/24.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class PracticeNoteContentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // TaskTableViewCellを登録
        tableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil), forCellReuseIdentifier: "TaskTableViewCell")
        
        // テーブルを再読み込み
        self.tableView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // データを表示
        printNoteData(noteData)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView?.reloadData()
            
            // 課題数によってテーブルビューの高さを設定
            self.tableView?.layoutIfNeeded()
            self.tableView?.updateConstraints()
            self.tableViewHeight.constant = CGFloat(self.tableView.contentSize.height)
        
            // PracticeNoteDetailViewControllerオブジェクトを取得
            if let obj = self.parent as? PracticeNoteDetailViewController {
                // containerViewの高さを設定
                obj.setContainerViewHeight(height: self.tableView.contentSize.height)
            }
        }
    }
    
    
    
    //MARK:- 変数の宣言
    
    var noteData = NoteData()
    
    
    
    //MARK:- UIの設定

    // テキスト
    @IBOutlet weak var physicalConditionTextView: UITextView!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // 編集ボタンの処理
    func editButton() {
        // 練習記録追加画面を取得
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddPracticeNoteViewController") as! AddPracticeNoteViewController
        
        // ノートデータの受け渡し
        nextView.noteData = self.noteData
        nextView.previousControllerName = "PracticeNoteDetailViewController"
        
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
