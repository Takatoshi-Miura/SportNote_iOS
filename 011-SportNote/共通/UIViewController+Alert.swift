//
//  UIViewController+Alert.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2021/02/16.
//  Copyright © 2021 Takatoshi Miura. All rights reserved.
//

import UIKit

public extension UIViewController {

    // MARK: Public Methods

    /**
     アラートを表示
     - Parameters:
      - title: タイトル
      - message: 説明文
      - actions: [okAction、cancelAction]等
     */
    func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    /**
     利用規約アラートを表示
     */
    func displayAgreement() {
        // 同意ボタン
        let agreeAction = UIAlertAction(title:"同意する",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // 次回以降、利用規約を表示しないようにする
            UserDefaults.standard.set(true, forKey: "ver1.5.0")
        }
        // 利用規約ボタン
        let termsAction = UIAlertAction(title:"利用規約を読む",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // 規約画面に遷移
            let url = URL(string: "https://sportnote-b2c92.firebaseapp.com/")
            UIApplication.shared.open(url!)
            // アラートが消えるため再度表示
            self.displayAgreement()
        }
        showAlert(title: "利用規約の更新", message: "本アプリの利用規約とプライバシーポリシーに同意します。", actions: [agreeAction, termsAction])
    }

}
