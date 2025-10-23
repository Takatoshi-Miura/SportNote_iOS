//
//  LoginViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/30.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import PKHUD
import RxSwift
import RxCocoa

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

    var delegate: LoginViewControllerDelegate?
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        bindViewModel()
    }

    /// 画面初期化
    private func initView() {
        initTextField(textField: loginTextField, placeholder: TITLE_MAIL_ADDRESS)
        initTextField(textField: passwordTextField, placeholder: TITLE_PASSWORD)
        passwordChangeButton.setTitle(TITLE_PASSWORD_RESET, for: .normal)
        createAccountButton.setTitle(TITLE_CREATE_ACCOUNT, for: .normal)
        deleteAccountButton.setTitle(TITLE_DELETE_ACCOUNT, for: .normal)
        cancelButton.setTitle(TITLE_CANCEL, for: .normal)
    }

    /// ViewModelのバインディング設定
    private func bindViewModel() {
        // ログイン状態の監視
        viewModel.isLoggedIn
            .subscribe(onNext: { [weak self] isLoggedIn in
                self?.updateUIForLoginState(isLoggedIn: isLoggedIn)
            })
            .disposed(by: disposeBag)

        // メールアドレスとパスワードの表示
        viewModel.emailAddress
            .bind(to: loginTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.password
            .bind(to: passwordTextField.rx.text)
            .disposed(by: disposeBag)

        // 認証イベントの監視
        viewModel.authEvent
            .subscribe(onNext: { [weak self] event in
                self?.handleAuthEvent(event)
            })
            .disposed(by: disposeBag)
    }

    /// ログイン状態に応じてUIを更新
    /// - Parameter isLoggedIn: ログイン状態
    private func updateUIForLoginState(isLoggedIn: Bool) {
        if isLoggedIn {
            label.text = TITLE_ALREADY_LOGIN
            loginButton.backgroundColor = UIColor.systemRed
            loginButton.setTitle(TITLE_LOGOUT, for: .normal)
        } else {
            label.text = TITLE_LOGIN_HELP
            loginButton.backgroundColor = UIColor.systemTeal
            loginButton.setTitle(TITLE_LOGIN, for: .normal)
        }
    }

    /// 認証イベントのハンドリング
    /// - Parameter event: 認証イベント
    private func handleAuthEvent(_ event: LoginViewModel.AuthEvent) {
        switch event {
        case .loading(let message):
            HUD.show(.labeledProgress(title: "", subtitle: message))

        case .loginSuccess:
            HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_LOGIN_SUCCESSFUL))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.loginVCUserDidLogin(self)
            }

        case .logoutSuccess:
            HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_LOGOUT_SUCCESSFUL))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.loginVCUserDidLogout(self)
            }

        case .createAccountSuccess:
            HUD.hide()
            self.delegate?.loginVCUserDidLogin(self)
            HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_DATA_TRANSFER_SUCCESSFUL))

        case .deleteAccountSuccess:
            HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_DELETE_ACCOUNT_SUCCESSFUL))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.loginVCUserDidLogout(self)
            }

        case .passwordResetEmailSent:
            HUD.show(.labeledSuccess(title: "", subtitle: MESSAGE_MAIL_SEND_SUCCESSFUL))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.delegate?.loginVCUserDidLogin(self)
            }

        case .error(let message):
            HUD.show(.labeledError(title: "", subtitle: message))
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {
                HUD.hide()
            }
        }
    }

    // MARK: - Action

    /// ログインボタンの処理
    @IBAction func tapLoginButton(_ sender: Any) {
        if viewModel.isLoggedIn.value {
            viewModel.logout()
        } else {
            guard let email = loginTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                return
            }
            viewModel.login(email: email, password: password)
        }
    }

    /// パスワード変更ボタンの処理
    @IBAction func tapPasswordChangeButton(_ sender: Any) {
        guard let email = loginTextField.text, !email.isEmpty else {
            showErrorAlert(message: MESSAGE_EMPTY_TEXT_ERROR_PASSWORD_RESET)
            return
        }

        showOKCancelAlert(title: TITLE_PASSWORD_RESET, message: MESSAGE_PASSWORD_RESET, OKAction: {
            self.viewModel.sendPasswordResetEmail(email: email)
        })
    }

    /// アカウント作成ボタンの処理
    @IBAction func tapCreateAccountButton(_ sender: Any) {
        guard let email = loginTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showErrorAlert(message: MESSAGE_EMPTY_TEXT_ERROR)
            return
        }

        showOKCancelAlert(title: TITLE_CREATE_ACCOUNT, message: MESSAGE_CREATE_ACCOUNT, OKAction: {
            self.viewModel.createAccount(email: email, password: password)
        })
    }

    /// アカウント削除ボタンの処理
    @IBAction func tapDeleteAccountButton(_ sender: Any) {
        guard viewModel.isLoggedIn.value else {
            showErrorAlert(message: MESSAGE_PLEASE_LOGIN)
            return
        }

        showOKCancelAlert(title: TITLE_DELETE_ACCOUNT, message: MESSAGE_DELETE_ACCOUNT, OKAction: {
            self.viewModel.deleteAccount()
        })
    }

    /// キャンセルボタンの処理
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.loginVCCancelDidTap(self)
    }

}
