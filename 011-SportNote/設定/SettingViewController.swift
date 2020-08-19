//
//  SettingViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/28.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    
    
    //MARK:- 変数の宣言
    
    // セルのタイトル
    let cellTitle = ["このアプリの使い方","データの引継ぎ"]
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //MARK:- テーブルビューの設定
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // タップしたセルによって遷移先を変える
        switch cellTitle[indexPath.row] {
        case "このアプリの使い方":
            // チュートリアル画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
            self.present(nextView, animated: true, completion: nil)
        case "データの引継ぎ":
            // ログイン画面へ遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(nextView, animated: true, completion: nil)
        default:
            // 何もしない
            print("")
        }
    }
    
    // セルの個数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count
    }
    
    // セルを返却
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        cell.textLabel!.text = cellTitle[indexPath.row]
        return cell
    }
    
    
    
    //MARK:- その他の処理
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            // UserDefaultsにユーザー情報を保存
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "address")
            userDefaults.removeObject(forKey: "password")
            userDefaults.synchronize()
            
            SVProgressHUD.showSuccess(withStatus: "ログアウトしました。")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            SVProgressHUD.showError(withStatus: "ログアウトに失敗しました。")
        }
    }
    
    

}
