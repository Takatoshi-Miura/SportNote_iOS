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
        
        // ログインしてるならログインボタンをログアウトボタンに変更
        setloginButton()
        
        // ログインしているなら情報をテキストフィールドに表示
        printUserInfo()
    }
    
    
    
    //MARK:- UIの設定
    
    // ラベル
    @IBOutlet weak var loginLabel: UILabel!
    
    // テキストフィールド
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // ボタン
    @IBOutlet weak var loginButton: UIButton!
    
    // ログインボタンの処理
    @IBAction func loginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // ログイン状態チェック
            if let _ = UserDefaults.standard.object(forKey: "address") as? String, let _ = UserDefaults.standard.object(forKey: "password") as? String {
                // ログアウト処理
                self.logout()
            } else {
                // ログイン処理
                self.login(mail: address, password: password)
            }
        }
    }
    
    // パスワードを忘れた場合ボタンの処理
    @IBAction func forgotPassword(_ sender: Any) {
        // パスワードリセット画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "PasswordResetViewController")
        present(nextView, animated: true, completion: nil)
    }
    
    // アカウント作成ボタンの処理
    @IBAction func createAccountButton(_ sender: Any) {
        // アカウント作成画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "CreateAccountViewController")
        present(nextView, animated: true, completion: nil)
    }
    
    // 閉じるボタンの処理
    @IBAction func closeButton(_ sender: Any) {
        // モーダルを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    

    //MARK:- 画面遷移
    
    // ノート画面に遷移する時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
            
            // ユーザーデータを削除
            let userData = UserData()
            userData.removeUserData()
            
            // UserDefaultsにユーザー情報を保存
            self.saveUserInfo(mail: address, password: pass)
            
            // メッセージが隠れてしまうため、遅延処理を行う
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                // ユーザーデータを更新
                let userData = UserData()
                userData.createUserData()
                
                // ノート画面に遷移
                self.performSegue(withIdentifier: "goTabBarController", sender: nil)
            }
        }
    }
    
    // ログアウトするメソッド
    func logout() {
        do {
            try Auth.auth().signOut()

            // ログアウト成功を通知
            SVProgressHUD.showSuccess(withStatus: "ログアウトしました。")
            
            // UserDefaultsのユーザー情報を削除
            removeUserInfo()
            
            // テキストフィールドをクリア
            mailAddressTextField.text = ""
            passwordTextField.text = ""
            
            // ユーザーIDを作成(初期値を登録)
            let uuid = NSUUID().uuidString
            UserDefaults.standard.register(defaults: ["userID":uuid])
            UserDefaults.standard.set(uuid, forKey: "userID")
            
            // メッセージが隠れてしまうため、遅延処理を行う
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                // ノート画面に遷移
                self.performSegue(withIdentifier: "goTabBarController", sender: nil)
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            SVProgressHUD.showError(withStatus: "ログアウトに失敗しました。")
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
    }
    
    // UserDefaultsからユーザー情報を削除するメソッド
    func removeUserInfo() {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "userID")
        userDefaults.removeObject(forKey: "address")
        userDefaults.removeObject(forKey: "password")
    }
    
    // ログインボタン/ログアウトボタンの設定
    func setloginButton() {
        // ログインチェック
        if let _ = UserDefaults.standard.object(forKey: "address") as? String, let _ = UserDefaults.standard.object(forKey: "password") as? String {
            // UIをログアウトボタンにセット
            loginButton.backgroundColor = UIColor.systemRed
            loginButton.setTitle("ログアウト", for: .normal)
        } else {
            // UIをログインボタンにセット
            loginButton.backgroundColor = UIColor.systemTeal
            loginButton.setTitle("ログイン", for: .normal)
        }
    }
    
    // ログイン情報をテキストフィールドに表示するメソッド
    func printUserInfo() {
        // ログインしていればUserDefaultsにデータが存在するはず
        if let address = UserDefaults.standard.object(forKey: "address") as? String, let password = UserDefaults.standard.object(forKey: "password") as? String {
            mailAddressTextField.text = address
            passwordTextField.text = password
            loginLabel.text = "下記アカウントでログイン済み"
        }
    }
    
}
