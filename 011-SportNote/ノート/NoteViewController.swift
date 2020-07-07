//
//  NoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import SVProgressHUD

class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
    
        // データのないセルを非表示
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // データ取得
        freeNoteData.loadFreeNoteData()
        target.loadTargetData()
        practiceNote.loadPracticeNoteData()
        competitionNote.loadCompetitionNoteData()
        
        // 時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            // テーブルデータ初期化
            self.sectionTitleInit()
            self.dataInSectionInit()
            
            self.targetData = self.target.targetData
            self.practiceNoteData = self.practiceNote.practiceNoteData
            self.competitionNoteData = self.competitionNote.competitionNoteData
            
            // targetDataが空の時は更新しない（エラー対策）
            if self.targetData.isEmpty == false {
                // テーブルデータ更新
                for index in 0...(self.targetData.count - 1) {
                    // 年間目標と月間目標の区別
                    if self.targetData[index].getMonth() == 13 {
                        self.sectionTitle.append("\(self.targetData[index].getYear())年:\(self.targetData[index].getDetail())")
                        self.dataInSection.append([])
                    } else {
                        self.sectionTitle.append("\(self.targetData[index].getMonth())月:\(self.targetData[index].getDetail())")
                        self.dataInSection.append(["ノート"])
                    }
                }
            }
        
            // テーブルビューを更新
            self.tableView?.reloadData()
            
            // HUDで処理中を非表示
            SVProgressHUD.dismiss()
        }
    }
    
    
    
    //MARK:- 変数の宣言
    
    // データ格納用
    var freeNoteData = FreeNote()
    var target = TargetData()
    var targetData = [TargetData]()
    var practiceNote = PracticeNote()
    var practiceNoteData = [PracticeNote]()
    var competitionNote = CompetitionNote()
    var competitionNoteData = [CompetitionNote]()
    
    // テーブル用
    var sectionTitle:[String] = ["フリーノート"]
    var dataInSection         = [["フリーノート"]]
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // ＋ボタンの処理
    @IBAction func addButton(_ sender: Any) {
        // ノート追加画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddViewController")
        self.present(nextView, animated: true, completion: nil)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataInSection[section].count     // セルの個数(ノート数)を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 最上位はフリーノートセル、それ以外はノートセル
        switch indexPath.section {
            case 0:
                // フリーノートセルを返却
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
                cell.textLabel!.text = freeNoteData.getTitle()
                cell.detailTextLabel!.text = freeNoteData.getDetail()
                return cell
            default:
                // ノートセルを返却
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for:indexPath)
                cell.textLabel?.text = dataInSection[indexPath.section][indexPath.row]
                
                return cell
        }
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String?{
        return sectionTitle[section]    //セクション名を返す
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count       //セクションの個数を返す
    }
    
    // セルをタップしたときの処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 編集時の処理
        if tableView.isEditing {
            // 選択されたセルの行番号を格納
        } else {
            // 通常時の処理
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            // 画面遷移
            if indexPath.section == 0 {
                // フリーノートセルがタップされたとき
                performSegue(withIdentifier: "goFreeNoteViewController", sender: nil)
            } else {
                // ノートセルがタップされたとき
            }
        }
    }
    
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFreeNoteViewController" {
            // 表示するデータを確認画面へ渡す
            let freeNoteViewController = segue.destination as! FreeNoteViewController
            freeNoteViewController.freeNoteData = freeNoteData
        }
    }
    
    // NoteViewControllerに戻ったときの処理
    @IBAction func goToNoteViewController(_segue:UIStoryboardSegue) {
    }
    
    
    
    //MARK:- その他のメソッド
    
    // 初期化sectionTitle
    func sectionTitleInit() {
        self.sectionTitle = ["フリーノート"]
    }
    
    // 初期化dataInSection
    func dataInSectionInit() {
        self.dataInSection = [["フリーノート"]]
    }
    
    
}
