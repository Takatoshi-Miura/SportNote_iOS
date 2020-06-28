//
//  LoginViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/23.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // テキストフィールド
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // ログインボタンの処理
    @IBAction func loginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // ログイン処理
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                // エラーのハンドリング
                if let error = error {
                    SVProgressHUD.showError(withStatus: "ログインに失敗しました。入力を確認してください。")
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "ログインしました。")
                
                // タブ画面に遷移
                // メッセージが隠れてしまうため、遅延処理を行う
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.performSegue(withIdentifier: "goTabBarController", sender: nil)
                }
            }
        }
    }
    
    
    // アカウント作成ボタンの処理
    @IBAction func createAccountButton(_ sender: Any) {
        // アドレス,パスワード名,アカウント名の入力を確認
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレス,パスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // アカウント作成処理
            Auth.auth().createUser(withEmail: mailAddressTextField.text!, password: passwordTextField.text!) { authResult, error in
                // エラーのハンドリング
                if let error = error  {
                    SVProgressHUD.showError(withStatus: "アカウント作成に失敗しました。時間をおいて再度お試しください。")
                    return
                }
                
                // アカウントの登録を通知
                SVProgressHUD.showSuccess(withStatus: "アカウントを作成しました。")
                
                // タブ画面に遷移
                // メッセージが隠れてしまうため、遅延処理を行う
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.performSegue(withIdentifier: "goTabBarController", sender: nil)
                }
            }
        }
    }
    
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // ログイン画面に戻ってくるときに呼び出される処理
    @IBAction func goToLogin(_segue:UIStoryboardSegue){
        // テキストフィールドをクリア
        mailAddressTextField.text = ""
        passwordTextField.text    = ""
    }
    
    
}
