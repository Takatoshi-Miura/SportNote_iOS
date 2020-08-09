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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        // ユーザー名が保存されてるなら自動ログイン
        if let address = UserDefaults.standard.object(forKey: "address") as? String, let password = UserDefaults.standard.object(forKey: "password") as? String {
            // テキストフィールドにセット
            mailAddressTextField.text = address
            passwordTextField.text = password
            
            // ログイン処理
            self.login(mail: address, password: password)
         }
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
    
    
    // アカウント作成ボタンの処理
    @IBAction func createAccountButton(_ sender: Any) {
        // アドレス,パスワード名,アカウント名の入力を確認
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            // アドレス,パスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // アカウント作成処理
            self.createAccount(mail: address, password: password)
        }
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
    
    // アカウントを作成するメソッド
    func createAccount(mail address:String,password pass:String) {
        // HUDで処理中を表示
        SVProgressHUD.show(withStatus: "アカウントを作成しています")
        
        // アカウント作成処理
        Auth.auth().createUser(withEmail: address, password: pass) { authResult, error in
            if error == nil {
                // エラーなし
            } else {
                // エラーのハンドリング
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                        case .invalidEmail:
                            SVProgressHUD.showError(withStatus: "メールアドレスの形式が違います。")
                        case .emailAlreadyInUse:
                            SVProgressHUD.showError(withStatus: "既にこのメールアドレスは使われています。")
                        case .weakPassword:
                            SVProgressHUD.showError(withStatus: "パスワードは6文字以上で入力してください。")
                        default:
                            SVProgressHUD.showError(withStatus: "エラーが起きました。しばらくしてから再度お試しください。")
                    }
                    return
                }
            }
            // アカウントの登録を通知
            SVProgressHUD.showSuccess(withStatus: "アカウントを作成しました。")

            // フリーノートデータを作成
            self.createFreeNoteData()
            
            // メッセージが隠れてしまうため、遅延処理を行う
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                // ノート画面に遷移
                self.performSegue(withIdentifier: "goTabBarController", sender: nil)
            }
        }
    }
    
    // Firebaseにフリーノートデータを作成するメソッド(アカウント作成時のみ実行)
    func createFreeNoteData() {
        // フリーノートデータを作成
        let freeNote = FreeNote()
        
        // ユーザーUIDをセット
        freeNote.setUserID(Auth.auth().currentUser!.uid)
        
        // 現在時刻をセット
        freeNote.setCreated_at(getCurrentTime())
        freeNote.setUpdated_at(freeNote.getCreated_at())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("FreeNoteData").document("\(freeNote.getUserID())").setData([
            "title"      : freeNote.getTitle(),
            "detail"     : freeNote.getDetail(),
            "userID"     : freeNote.getUserID(),
            "created_at" : freeNote.getCreated_at(),
            "updated_at" : freeNote.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
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
        userDefaults.set(address, forKey:"address")
        userDefaults.set(pass,forKey:"password")
        userDefaults.synchronize()
    }
    
    
    
}
