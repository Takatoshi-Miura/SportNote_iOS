//
//  LoginViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/23.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    //MARK:- UIの設定
    
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
            
            // ログイン処理
            self.login(mail: address, password: password)
        }
    }
    
    // パスワードを忘れた場合ボタンの処理
    @IBAction func forgotPassword(_ sender: Any) {
        // パスワードリセット画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "PasswordResetViewController")
        setTransitionAnimation(direction: "Right")
        present(nextView, animated: false, completion: nil)
    }
    
    // アカウント作成ボタンの処理
    @IBAction func createAccountButton(_ sender: Any) {
        // アカウント作成画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController")
        setTransitionAnimation(direction: "Right")
        present(nextView, animated: false, completion: nil)
    }
    
    

    //MARK:- 画面遷移
    
    // ログイン画面に戻ってくるときに呼び出される処理
    @IBAction func goToLogin(_segue:UIStoryboardSegue){
        // テキストフィールドをクリア
        mailAddressTextField.text = ""
        passwordTextField.text    = ""
    }
    
    // ノート画面に遷移する時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTabBarController" {
            // UserDefaultsにユーザー情報を保存
            self.saveUserInfo(mail: mailAddressTextField.text!, password: passwordTextField.text!)
        }
    }
    
    // 画面遷移のアニメーションを設定するメソッド
    func setTransitionAnimation(direction:String) {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = CATransitionType.push
        
        // 方向を設定
        if direction == "Right" {
            transition.subtype = CATransitionSubtype.fromRight
        } else {
            transition.subtype = CATransitionSubtype.fromLeft
        }
        view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    
    
    //MARK:- データベース関連
    
    // ログインするメソッド
    func login(mail address:String,password pass:String) {
        // HUDで処理中を表示
        SVProgressHUD.show(withStatus: "ログインしています")
        
        // ログイン処理
        Auth.auth().signIn(withEmail: address, password: pass) { authResult, error in
            if error == nil {
                // エラーなし
            } else {
                // エラーのハンドリング
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                        case .invalidEmail:
                            SVProgressHUD.showError(withStatus: "メールアドレスの形式が違います。")
                        case .wrongPassword:
                            SVProgressHUD.showError(withStatus: "パスワードが間違っています。")
                        default:
                            SVProgressHUD.showError(withStatus: "ログインに失敗しました。入力を確認して下さい。")
                    }
                    return
                }
            }
            // ログイン成功を通知
            SVProgressHUD.showSuccess(withStatus: "ログインしました。")
            
            // メッセージが隠れてしまうため、遅延処理を行う
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                // ノート画面に遷移
                self.performSegue(withIdentifier: "goTabBarController", sender: nil)
            }
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // キーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    // UserDefaultsにユーザー情報を保存するメソッド
    func saveUserInfo(mail address:String,password pass:String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(Auth.auth().currentUser!.uid, forKey: "userID")
        userDefaults.set(address, forKey:"address")
        userDefaults.set(pass,forKey:"password")
        userDefaults.synchronize()
    }
    
    
    
}
