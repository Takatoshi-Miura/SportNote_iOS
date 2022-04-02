//
//  CreateAccountViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/08/18.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CreateAccountViewController: UIViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // データ取得
        loadFreeNoteData()
        loadTargetData()
        loadNoteData()
        loadTaskData()
    }
    

    //MARK:- UIの設定
    
    // テキストフィールド
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // アカウント作成ボタンの処理
    @IBOutlet weak var createAccountButton: UIButton!
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
    
    // 閉じるボタンの処理
    @IBOutlet weak var closeButton: UIButton!
    @IBAction func closeButton(_ sender: Any) {
        // モーダルを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- 変数の宣言
    
    // データ格納用
    var dataManager = DataManager()
    
    
    //MARK:- データベース関連
    
    // アカウントを作成するメソッド
    func createAccount(mail address:String,password pass:String) {
        // HUDで処理中を表示
        SVProgressHUD.show(withStatus: "アカウントを作成しています")
        
        // ボタン無効化
        createAccountButton.isEnabled = false
        closeButton.isEnabled = false
        
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
            
            // FirebaseのユーザーIDをセット
            UserDefaultsKey.userID.set(value: Auth.auth().currentUser!.uid)
            UserDefaultsKey.address.set(value: address)
            UserDefaultsKey.password.set(value: pass)
            
            // データの引継ぎを通知
            SVProgressHUD.show(withStatus: "データの引継ぎをしています")
            
            // FirebaseアカウントのIDでデータを複製
            self.reproductionUserData()
        }
    }
    
    // データを複製するメソッド
    func reproductionUserData() {
        // フリーノートデータを複製
        createFreeNoteData({
            // 目標データを複製
            self.createTargetData(self.dataManager.targetDataArray, {
                // ノートデータを複製
                self.createNoteData(self.dataManager.noteDataArray, {
                    // 課題データを複製
                    self.createTaskData(self.dataManager.taskDataArray, {
                        SVProgressHUD.showSuccess(withStatus: "引継ぎに成功しました")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            // ノート画面へ遷移
                            let storyboard: UIStoryboard = self.storyboard!
                            let nextView = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                            self.present(nextView, animated: true, completion: nil)
                        }
                    })
                })
            })
        })
    }
    
    // Firebaseからフリーノートデータを読み込むメソッド
    func loadFreeNoteData() {
        dataManager.getFreeNoteData({})
    }
    
    // Firebaseから目標データを取得するメソッド
    func loadTargetData() {
        dataManager.getTargetData({})
    }
    
    // Firebaseからデータを取得するメソッド
    func loadNoteData() {
        dataManager.getNoteData({})
    }
    
    // 課題データを取得するメソッド
    func loadTaskData() {
        dataManager.getAllTaskData({})
    }
    
    // フリーノートデータを作成するメソッド(新IDで複製)
    func createFreeNoteData(_ completion: @escaping () -> ()) {
        SVProgressHUD.show(withStatus: "フリーノートの引継ぎをしています")
        dataManager.createFreeNoteData({
            completion()
        })
    }
    
    // 目標データを作成するメソッド(新IDで複製)
    func createTargetData(_ targetDataArray:[Target_old], _ completion: @escaping () -> ()) {
        SVProgressHUD.show(withStatus: "目標データの引継ぎをしています")
        var count = 0
        for targetData in targetDataArray {
            dataManager.copyTargetData(targetData, {
                count += 1
                if count == targetDataArray.count {
                    completion()
                }
            })
        }
    }
    
    // ノートデータを複製するメソッド
    func createNoteData(_ noteDataArray:[Note_old], _ completion: @escaping () -> ()) {
        SVProgressHUD.show(withStatus: "ノートデータの引継ぎをしています")
        var count = 0
        for noteData in noteDataArray {
            dataManager.copyNoteData(noteData, {
                count += 1
                if count == noteDataArray.count {
                    completion()
                }
            })
        }
    }
    
    // 課題データを複製するメソッド
    func createTaskData(_ taskDataArray:[Task_old], _ completion: @escaping () -> ()) {
        // 課題データを複製
        SVProgressHUD.show(withStatus: "課題データの引継ぎをしています")
        var count = 0
        for taskData in taskDataArray {
            dataManager.copyTaskData(taskData, {
                count += 1
                if count == taskDataArray.count {
                    completion()
                }
            })
        }
    }

}
