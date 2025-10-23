//
//  LoginViewModel.swift
//  011-SportNote
//
//  Created by Claude on 2025/10/23.
//  Copyright © 2025 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Firebase

class LoginViewModel {

    // MARK: - Variable

    /// ログイン状態
    let isLoggedIn: BehaviorRelay<Bool>
    /// メールアドレス
    let emailAddress: BehaviorRelay<String>
    /// パスワード
    let password: BehaviorRelay<String>

    // イベント通知用
    enum AuthEvent {
        case loginSuccess
        case logoutSuccess
        case createAccountSuccess
        case deleteAccountSuccess
        case passwordResetEmailSent
        case error(String)
        case loading(String)
    }

    let authEvent = PublishRelay<AuthEvent>()
    private let disposeBag = DisposeBag()

    // MARK: - Initializer

    init() {
        // UserDefaultsから保存された情報を取得
        let savedEmail = UserDefaults.standard.object(forKey: "address") as? String ?? ""
        let savedPassword = UserDefaults.standard.object(forKey: "password") as? String ?? ""
        let hasLoginInfo = !savedEmail.isEmpty && !savedPassword.isEmpty

        self.isLoggedIn = BehaviorRelay(value: hasLoginInfo)
        self.emailAddress = BehaviorRelay(value: savedEmail)
        self.password = BehaviorRelay(value: savedPassword)
    }

    // MARK: - Authentication Methods

    /// ログイン処理
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    func login(email: String, password: String) {
        authEvent.accept(.loading(MESSAGE_DURING_LOGIN_PROCESS))

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error as? AuthErrorCode {
                let errorMessage = self.getLoginErrorMessage(error.code)
                self.authEvent.accept(.error(errorMessage))
            } else {
                // ログイン成功時の処理
                self.saveUserCredentials(email: email, password: password)
                self.clearRealmData()
                self.isLoggedIn.accept(true)
                self.emailAddress.accept(email)
                self.password.accept(password)
                self.authEvent.accept(.loginSuccess)
            }
        }
    }

    /// ログアウト処理
    func logout() {
        do {
            try Auth.auth().signOut()
            self.performLogoutCleanup()
            self.authEvent.accept(.logoutSuccess)
        } catch {
            self.authEvent.accept(.error(MESSAGE_LOGOUT_ERROR))
        }
    }

    /// アカウント作成処理
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    func createAccount(email: String, password: String) {
        authEvent.accept(.loading(MESSAGE_DURING_CREATE_ACCOUNT_PROCESS))

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error as? AuthErrorCode {
                let errorMessage = self.getCreateAccountErrorMessage(error.code)
                self.authEvent.accept(.error(errorMessage))
            } else {
                // アカウント作成成功時の処理
                guard let userID = Auth.auth().currentUser?.uid else { return }

                self.saveUserCredentials(email: email, password: password)
                self.updateRealmUserID(userID: userID)
                self.isLoggedIn.accept(true)
                self.emailAddress.accept(email)
                self.password.accept(password)

                // Firebaseと同期
                self.syncWithFirebase()
            }
        }
    }

    /// アカウント削除処理
    func deleteAccount() {
        authEvent.accept(.loading(MESSAGE_DURING_DELETE_ACCOUNT))

        Auth.auth().currentUser?.delete { [weak self] error in
            guard let self = self else { return }

            if error == nil {
                self.performLogoutCleanup()
                self.authEvent.accept(.deleteAccountSuccess)
            } else {
                self.authEvent.accept(.error(MESSAGE_DELETE_ACCOUNT_ERROR))
            }
        }
    }

    /// パスワードリセットメールを送信
    /// - Parameter email: メールアドレス
    func sendPasswordResetEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }

            if error != nil {
                self.authEvent.accept(.error(MESSAGE_MAIL_SEND_ERROR))
            } else {
                self.authEvent.accept(.passwordResetEmailSent)
            }
        }
    }

    // MARK: - Private Helper Methods

    /// ユーザー認証情報をUserDefaultsに保存
    /// - Parameters:
    ///   - email: メールアドレス
    ///   - password: パスワード
    private func saveUserCredentials(email: String, password: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        UserDefaultsKey.userID.set(value: userID)
        UserDefaultsKey.address.set(value: email)
        UserDefaultsKey.password.set(value: password)
    }

    /// Realmデータを全削除
    private func clearRealmData() {
        let realmManager = RealmManager()
        realmManager.deleteAllRealmData()
    }

    /// RealmデータのユーザーIDを更新
    /// - Parameter userID: 新しいユーザーID
    private func updateRealmUserID(userID: String) {
        let realmManager = RealmManager()
        realmManager.updateAllRealmUserID(userID: userID)
    }

    /// Firebaseと同期
    private func syncWithFirebase() {
        let syncManager = SyncManager()
        Task {
            await syncManager.syncDatabase()
            // 同期完了後のイベント通知
            DispatchQueue.main.async { [weak self] in
                self?.authEvent.accept(.createAccountSuccess)
            }
        }
    }

    /// ログアウト時の共通処理
    private func performLogoutCleanup() {
        // Realmデータを全削除
        clearRealmData()

        // UserDefaultsのユーザー情報を削除&新規作成
        UserDefaultsKey.userID.remove()
        UserDefaultsKey.address.remove()
        UserDefaultsKey.password.remove()
        UserDefaultsKey.userID.set(value: NSUUID().uuidString)

        // ViewModelの状態をリセット
        isLoggedIn.accept(false)
        emailAddress.accept("")
        password.accept("")
    }

    /// ログインエラーメッセージを取得
    /// - Parameter errorCode: エラーコード
    /// - Returns: エラーメッセージ
    private func getLoginErrorMessage(_ errorCode: AuthErrorCode.Code) -> String {
        switch errorCode {
        case .invalidEmail:
            return MESSAGE_INVALID_EMAIL
        case .wrongPassword:
            return MESSAGE_WRONG_PASSWORD
        default:
            return MESSAGE_LOGIN_ERROR
        }
    }

    /// アカウント作成エラーメッセージを取得
    /// - Parameter errorCode: エラーコード
    /// - Returns: エラーメッセージ
    private func getCreateAccountErrorMessage(_ errorCode: AuthErrorCode.Code) -> String {
        switch errorCode {
        case .invalidEmail:
            return MESSAGE_INVALID_EMAIL
        case .emailAlreadyInUse:
            return MESSAGE_EMAIL_ALREADY_INUSE
        case .weakPassword:
            return MESSAGE_WEAK_PASSWORD
        default:
            return MESSAGE_CREATE_ACCOUNT_ERROR
        }
    }
}
