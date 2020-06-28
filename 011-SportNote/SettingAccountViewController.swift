//
//  SettingAccountViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/28.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingAccountViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // ログアウトボタンの処理
    @IBAction func logoutButton(_ sender: Any) {
        // ログアウト処理
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            SVProgressHUD.showSuccess(withStatus: "ログアウトしました。")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            SVProgressHUD.showError(withStatus: "ログアウトに失敗しました。")
        }
        
        // ログイン画面へ遷移
    }
    
    
    
    



}
