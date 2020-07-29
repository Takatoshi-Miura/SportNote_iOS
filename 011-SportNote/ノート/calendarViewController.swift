//
//  calendarViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/29.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import FSCalendar

class calendarViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーのボタンを宣言
        listButton   = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(listButtonTapped(_:)))
        addButton    = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped(_:)))
        editButtonItem.title = "編集"
        
        // ナビゲーションバーのボタンを追加
        navigationItem.leftBarButtonItem   = editButtonItem
        navigationItem.rightBarButtonItems = [addButton,listButton]
        
        // セルの複数選択を許可
        tableView.allowsMultipleSelectionDuringEditing = true
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    
    //MARK:- 変数の宣言
    
    // ナビゲーションバー用のボタン
    var listButton:UIBarButtonItem!     // リストボタン
    var addButton:UIBarButtonItem!      // 追加ボタン
    var deleteButton:UIBarButtonItem!   // ゴミ箱ボタン
    
    // テーブル用
    var dataArray:[String] = []         // セルに表示するデータを格納する配列
    var sectionTitle:[String] = []      // セクションタイトル
    var freeNoteData = FreeNote()
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noteTableView: UITableView!
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            // 編集開始
            self.editButtonItem.title = "完了"
            
            // ナビゲーションバーに追加ボタン,ゴミ箱ボタンを表示
            self.navigationItem.rightBarButtonItems = [addButton,deleteButton]
        } else {
            // 編集終了
            self.editButtonItem.title = "編集"
            
            // ナビゲーションバーに追加ボタンを表示
            self.navigationItem.rightBarButtonItems = [addButton,listButton]
        }
        // 編集モード時のみ複数選択可能とする
        tableView.isEditing = editing
    }
    
    // リストボタンの処理
    @objc func listButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    // 課題追加ボタンの処理
    @objc func addButtonTapped(_ sender: UIBarButtonItem) {
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"データを追加",message:"入力してください",preferredStyle:UIAlertController.Style.alert)
        
        // テキストエリアを追加
        alertController.addTextField(configurationHandler:nil)
        
        // OKボタンの宣言
        let okAction = UIAlertAction(title:"OK",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            if let textField = alertController.textFields?.first {
                // dataArrayとテーブルに追加
                self.dataArray.insert(textField.text!,at:0)
                self.tableView.insertRows(at:[IndexPath(row:0,section:0)],with:UITableView.RowAnimation.right)
                
                // データを保存
                self.saveData()
            }
        }
        // CANCELボタンの宣言
        let cancelButton = UIAlertAction(title:"CANCEL",style:UIAlertAction.Style.cancel,handler:nil)
        
        // ボタンを追加
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        
        //アラートダイアログを表示
        present(alertController,animated:true,completion:nil)
    }
    
    // ゴミ箱ボタンの処理
    @objc func deleteButtonTapped(_ sender: UIBarButtonItem) {
        // 選択要素のIndexを降順にソートする
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
        
        // Indexの大きいデータから順に削除
        for indexPathList in sortedIndexPaths {
            self.dataArray.remove(at: indexPathList.row)
            self.tableView.deleteRows(at: [indexPathList], with: UITableView.RowAnimation.right)
        }
        
        // データを保存
        self.saveData()
        
        // 編集状態を解除
        self.setEditing(false, animated: true)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    // セルの数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return 1    // フリーノートセルのみ
        } else {
            return self.dataArray.count     // 選択された日付に保存されているノート数
        }
    }
    
    // セル(表示内容)を返却
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            // フリーノートセルを返却
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "freeNoteCell", for: indexPath)
            cell.textLabel!.text = freeNoteData.getTitle()
            cell.detailTextLabel!.text = freeNoteData.getDetail()
            cell.detailTextLabel?.textColor = UIColor.systemGray
            return cell
        } else {
            // ノートセルを返却
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for:indexPath)
            //cell.textLabel?.text       = dataInSection[indexPath.section][indexPath.row].getCellTitle()
            //cell.detailTextLabel?.text = dataInSection[indexPath.section][indexPath.row].getNoteType()
//            if dataInSection[indexPath.section][indexPath.row].getNoteType() == "練習記録" {
//                cell.detailTextLabel?.textColor = UIColor.systemGreen
//            } else {
//                cell.detailTextLabel?.textColor = UIColor.systemRed
//            }
            return cell
        }
    }
    
    // セルの編集可否設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0 {
            return false    // フリーノートは編集不可
        } else {
            return true     // ノートセルは編集可能
        }
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            // 編集時の処理
            
        } else {
            // 通常時の処理
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
    
    // 左スワイプの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // dataArrayとテーブルから削除
            self.dataArray.remove(at:indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
            
            // データを保存
            self.saveData()
        }
    }
    
    
    
    //MARK:- 画面遷移
    
    
    
    //MARK:- その他のメソッド

    // データをUserDefaultsに保存するメソッド
    func saveData() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.dataArray,forKey:"dataArray")
        userDefaults.synchronize()
    }

}
