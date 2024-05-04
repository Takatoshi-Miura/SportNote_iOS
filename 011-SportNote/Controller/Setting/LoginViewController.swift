//
//  LoginViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/30.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import PKHUD
import Firebase

protocol LoginViewControllerDelegate: AnyObject {
    // ログイン時の処理
    func loginVCUserDidLogin(_ viewController: UIViewController)
    // ログイン時の処理
    func loginVCUserDidLogout(_ viewController: UIViewController)
    // キャンセルタップ時の処理
    func loginVCCancelDidTap(_ viewController: UIViewController)
}

class LoginViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordChangeButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    private var isLogin: Bool = false
    var delegate: LoginViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // ログイン状態の判定
        if let _ = UserDefaults.standard.object(forKey: "address") as? String,
           let _ = UserDefaults.standard.object(forKey: "password") as? String
        {
            isLogin = true
        }
        initView()
    }
    
    ///画面初期化
    private func initView() {
        initTextField(textField: loginTextField, placeholder: TITLE_MAIL_ADDRESS)
        initTextField(textField: passwordTextField, placeholder: TITLE_PASSWORD)
        if isLogin {
            label.text = TITLE_ALREADY_LOGIN
            loginButton.backgroundColor = UIColor.systemRed
            loginButton.setTitle(TITLE_LOGOUT, for: .normal)
            if let address = UserDefaults.standard.object(forKey: "address") as? String {
                loginTextField.text = address
            }
            if let password = UserDefaults.standard.object(forKey: "password") as? String {
                passwordTextField.text = password
            }
        } else {
            label.text = TITLE_LOGIN_HELP
            loginButton.backgroundColor = UIColor.systemTeal
            loginButton.setTitle(TITLE_LOGIN, for: .normal)
        }
        passwordChangeButton.setTitle(TITLE_PASSWORD_RESET, for: .normal)
        createAccountButton.setTitle(TITLE_CREATE_ACCOUNT, for: .normal)
        deleteAccountButton.setTitle(TITLE_DELETE_ACCOUNT, for: .normal)
        cancelButton.setTitle(TITLE_CANCEL, for: .normal)
    }
    
    // MARK: - Action
    
    /// ログインボタンの処理
    @IBAction func tapLoginButton(_ sender: Any) {
        if isLogin {
            logout()
        } else {
            login(mail: loginTextField.text!, password: passwordTextField.text!)
        }
    }
    
    /// パスワード変更ボタンの処理
    @IBAction func tapPasswordChangeButton(_ sender: Any) {
        if loginTextField.text == "" {
            showErrorAlert(message: MESSAGE_EMPTY_TEXT_ERROR_PASSWORD_RESET)
            return
        }
        showOKCancelAlert(title: TITLE_PASSWORD_RESET, message:MESSAGE_PASSWORD_RESET, OKAction: {
            self.sendPasswordResetMail(mail: self.loginTextField.text!)
        })
    }
    
    /// アカウント作成ボタンの処理
    @IBAction func tapCreateAccountButton(_ sender: Any) {
        if loginTextField.text == "" || passwordTextField.text == "" {
            showErrorAlert(message: MESSAGE_EMPTY_TEXT_ERROR)
            return
        }
        showOKCancelAlert(title: TITLE_CREATE_ACCOUNT, message: MESSAGE_CREATE_ACCOUNT, OKAction: {
            self.createAccount(mail: self.loginTextField.text!, password: self.passwordTextField.text!)
        })
    }
    
    /// アカウント削除ボタンの処理
    @IBAction func tapDeleteAccountButton(_ sender: Any) {
        if !isLogin {
            showErrorAlert(message: MESSAGE_PLEASE_LOGIN)
            return
        }
        showOKCancelAlert(title: TITLE_DELETE_ACCOUNT, message: MESSAGE_DELETE_ACCOUNT, OKAction: {
            self.deleteAccount()
        })
    }
    
    /// キャンセルボタンの処理
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.loginVCCancelDidTap(self)
    }
    
    /// ログイン処理
    /// - Parameters:
    ///    - mail: メールアドレス
    ///    - password: パスワード
    func login(mail address: String, password pass: String) {
        HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_DURING_LOGIN_PROCESS))
        
        Auth.auth().signIn(withEmail: address, password: pass) { authResult, error in
            if let error = error as? AuthErrorCode {
                switch error.code {
                case .invalidEmail:
                    HUD.show(.labeledError(title: "", subtitle: MESSAGE_INVALID_EMAIL))
                case .wrongPassword:
                    HUD.show(.labeledError(title: "", subtitle: MESSAGE_WRONG_PASSWORD))
                default:
                    HUD.show(.labeledError(title: "", subtitle: MESSAGE_LOGIN_ERROR))
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                    HUD.hide()
                    return
                }
            } else {
                // UserDefaultsにユーザー情報を保存
                UserDefaultsKey.userID.set(value: Auth.auth().currentUser!.uid)
                UserDefaultsKey.address.set(value: address)
                UserDefaultsKey.password.set(value: pass)
                
                // Realmデータを全削除
                let realmManager = RealmManager()
                realmManager.deleteAllRealmData()
                
                // メッセージが隠れてしまうため、遅延処理を行ってから画面遷移
                HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_LOGIN_SUCCESSFUL))
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.delegate?.loginVCUserDidLogin(self)
                }
            }
        }
    }
    
    /// ログアウト処理
    func logout() {
        do {
            try Auth.auth().signOut()
            
            self.actionAfterLogout()
            
            // メッセージが隠れてしまうため、遅延処理を行う
            HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_LOGOUT_SUCCESSFUL))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.loginVCUserDidLogout(self)
            }
        } catch _ as NSError {
            HUD.hide()
            showErrorAlert(message: MESSAGE_LOGOUT_ERROR)
        }
    }
    
    /// パスワードリセットメールを送信
    /// - Parameters:
    ///    - mail: メールアドレス
    func sendPasswordResetMail(mail address: String) {
        Auth.auth().sendPasswordReset(withEmail: address) { (error) in
            if error != nil {
                self.showErrorAlert(message: MESSAGE_MAIL_SEND_ERROR)
                return
            }
            HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_MAIL_SEND_SUCCESSFUL))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.loginVCUserDidLogin(self)
            }
        }
    }
    
    /// アカウント作成処理
    /// - Parameters:
    ///    - mail: メールアドレス
    ///    - password: パスワード
    func createAccount(mail address: String, password pass: String) {
        HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_DURING_CREATE_ACCOUNT_PROCESS))
        
        Auth.auth().createUser(withEmail: address, password: pass) { authResult, error in
            if let error = error as? AuthErrorCode {
                HUD.hide()
                switch error.code {
                    case .invalidEmail:
                        HUD.show(.labeledError(title: "", subtitle: MESSAGE_INVALID_EMAIL))
                    case .emailAlreadyInUse:
                        HUD.show(.labeledError(title: "", subtitle: MESSAGE_EMAIL_ALREADY_INUSE))
                    case .weakPassword:
                        HUD.show(.labeledError(title: "", subtitle: MESSAGE_WEAK_PASSWORD))
                    default:
                        HUD.show(.labeledError(title: "", subtitle: MESSAGE_CREATE_ACCOUNT_ERROR))
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                    HUD.hide()
                    return
                }
            } else {
                // FirebaseのユーザーIDとログイン情報を保存
                UserDefaultsKey.userID.set(value: Auth.auth().currentUser!.uid)
                UserDefaultsKey.address.set(value: address)
                UserDefaultsKey.password.set(value: pass)
                
                // RealmデータのuserIDを新しいIDに更新
                let realmManager = RealmManager()
                realmManager.updateAllRealmUserID(userID: Auth.auth().currentUser!.uid)
                
                // Firebaseと同期
                let syncManager = SyncManager()
                Task {
                    await syncManager.syncDatabase()
                    HUD.hide()
                    self.delegate?.loginVCUserDidLogin(self)
                    HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_DATA_TRANSFER_SUCCESSFUL))
                }
            }
        }
    }
    
    /// アカウント削除処理
    private func deleteAccount() {
        HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_DURING_DELETE_ACCOUNT))
        Auth.auth().currentUser?.delete { (error) in
            if error == nil {
                self.actionAfterLogout()
                
                // メッセージが隠れてしまうため、遅延処理を行う
                HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_DELETE_ACCOUNT_SUCCESSFUL))
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.delegate?.loginVCUserDidLogout(self)
                }
            } else {
                HUD.hide()
                self.showErrorAlert(message: MESSAGE_DELETE_ACCOUNT_ERROR)
            }
        }
    }
    
    /// ログアウト時の共通処理
    private func actionAfterLogout() {
        // テキストフィールドをクリア
        self.loginTextField.text = ""
        self.passwordTextField.text = ""
        
        // Realmデータを全削除
        let realmManager = RealmManager()
        realmManager.deleteAllRealmData()
        
        // UserDefaultsのユーザー情報を削除&新規作成
        UserDefaultsKey.userID.remove()
        UserDefaultsKey.address.remove()
        UserDefaultsKey.password.remove()
        UserDefaultsKey.userID.set(value: NSUUID().uuidString)
    }
    
}

