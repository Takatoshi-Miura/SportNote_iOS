//
//  NoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    

    // ＋ボタンの処理
    @IBAction func addButton(_ sender: Any) {
    }
    
    // ノート数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 最上位はフリーノートセル、それ以外はノートセル
        switch indexPath.row {
            case 0:
                // フリーノートセルを返却
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "freeNoteCell", for: indexPath)
                cell.textLabel!.text = "フリーノート"
                cell.detailTextLabel!.text = "常に最上位に表示されるノートです。"
                return cell
            default:
                // ノートセルを返却
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "freeNoteCell", for: indexPath)
                return cell
        }
    }
    
}
