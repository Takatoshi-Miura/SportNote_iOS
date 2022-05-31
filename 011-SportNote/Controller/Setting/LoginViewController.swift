//
//  LoginViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/30.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: AnyObject {
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
    func initView() {
        loginTextField.placeholder = TITLE_MAIL_ADDRESS
        passwordTextField.placeholder = TITLE_PASSWORD
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
        cancelButton.setTitle(TITLE_CANCEL, for: .normal)
    }
    
    // MARK: - Action
    
    @IBAction func tapLoginButton(_ sender: Any) {
        if isLogin {
            // TODO: ログアウト処理
        } else {
            // TODO: ログイン処理
        }
    }
    
    @IBAction func tapPasswordChangeButton(_ sender: Any) {
    }
    
    @IBAction func tapCreateAccountButton(_ sender: Any) {
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.loginVCCancelDidTap(self)
    }
    
}

