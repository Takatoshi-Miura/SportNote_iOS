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
        
        // ツールバーを作成
        createToolBar()
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
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // ログイン処理
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
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
                
                // タブ画面に遷移
                // メッセージが隠れてしまうため、遅延処理を行う
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.performSegue(withIdentifier: "goTabBarController", sender: nil)
                }
            }
        }
    }
    
    

    //MARK:- 画面遷移
    
    // ログイン画面に戻ってくるときに呼び出される処理
    @IBAction func goToLogin(_segue:UIStoryboardSegue){
        // テキストフィールドをクリア
        mailAddressTextField.text = ""
        passwordTextField.text    = ""
    }
    
    
    
    //MARK:- その他のメソッド
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // ツールバーを作成するメソッド
    func createToolBar() {
        // ツールバーのインスタンスを作成
        let toolBar = UIToolbar()

        // ツールバーに配置するアイテムのインスタンスを作成
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let okButton: UIBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapOkButton(_:)))

        // アイテムを配置
        toolBar.setItems([flexibleItem, okButton], animated: true)

        // ツールバーのサイズを指定
        toolBar.sizeToFit()
        
        // テキストフィールドにツールバーを設定
        mailAddressTextField.inputAccessoryView = toolBar
        passwordTextField.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
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
    
    // Firebaseにデータを作成するメソッド(アカウント作成時のみ実行)
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
    
}
