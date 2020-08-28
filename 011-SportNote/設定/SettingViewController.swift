//
//  SettingViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/28.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import MessageUI

class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    
    
    //MARK:- 変数の宣言
    
    // セルのタイトル
    let cellTitle = ["このアプリの使い方","データの引継ぎ","お問い合わせ"]
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //MARK:- テーブルビューの設定
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // タップしたセルによって遷移先を変える
        switch cellTitle[indexPath.row] {
        case "このアプリの使い方":
            // チュートリアル画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
            self.present(nextView, animated: true, completion: nil)
        case "データの引継ぎ":
            // ログイン画面へ遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(nextView, animated: true, completion: nil)
        case "お問い合わせ":
            // メーラーを起動
            self.startMailer()
        default:
            // 何もしない
            print("")
        }
    }
    
    // セルの個数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitle.count
    }
    
    // セルを返却
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        cell.textLabel!.text = cellTitle[indexPath.row]
        return cell
    }
    
    
    
    //MARK:- その他のメソッド
    
    // メーラーを宣言するメソッド
    func startMailer() {
        // メールを送信できるかチェック
        if MFMailComposeViewController.canSendMail() == false {
            SVProgressHUD.showError(withStatus: "メールアカウントが未設定です。Apple社の「メール」アプリにてアカウントを設定して下さい。")
            return
        }

        // メーラーの宣言
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        
        // 送信先(Toアドレス)の設定
        let toRecipients = ["SportsNote開発者<it6210ge@gmail.com>"]
        mailViewController.setToRecipients(toRecipients)
        
        // 件名の設定
        mailViewController.setSubject("件名例：バグの報告")
        
        // 本文の設定
        mailViewController.setMessageBody("お問い合わせ内容をご記入下さい", isHTML: false)

        // メーラーを起動
        self.present(mailViewController, animated: true, completion: nil)
    }
    
    // メーラーを閉じるメソッド
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Email Send Cancelled")
            break
        case .saved:
            print("Email Saved as a Draft")
            break
        case .sent:
            SVProgressHUD.showSuccess(withStatus: "メールを送信しました。\n開発者からの返信をお待ち下さい。")
            break
        case .failed:
            SVProgressHUD.showError(withStatus: "メールを送信できませんでした。")
            break
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }

}
