//
//  PasswordResetViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/08/18.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PasswordResetViewController: UIViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    //MARK:- UIの設定
    
    // メールアドレス入力欄
    @IBOutlet weak var mailAddressTextField: UITextField!
    
    // リセットメール送信ボタンの処理
    @IBAction func passwordResetButton(_ sender: Any) {
        // アドレスが入力されていない時は何もしない
        if mailAddressTextField.text!.isEmpty {
            SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
            return
        } else {
            // パスワードリセットメールを送信
            self.sendPasswordResetMail()
        }
    }
    
    // 閉じるボタンの処理
    @IBAction func closeButton(_ sender: Any) {
        // モーダルを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK:- その他のメソッド
    
    // パスワードリセットメールを送信するメソッド
    func sendPasswordResetMail() {
        Auth.auth().sendPasswordReset(withEmail: mailAddressTextField.text!) { (error) in
            if error == nil {
                // メール送信を通知
                SVProgressHUD.showSuccess(withStatus: "メールを送信しました")
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    // ログイン画面に遷移
                    let storyboard: UIStoryboard = self.storyboard!
                    let nextView = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(nextView, animated: true, completion: nil)
                }
            } else {
                // エラーを通知
                SVProgressHUD.showError(withStatus: "メールを送信できませんでした")
            }
        }
    }

    

}
