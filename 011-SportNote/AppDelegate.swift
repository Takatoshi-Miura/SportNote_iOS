//
//  AppDelegate.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/23.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Admob広告を追加
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // 初回起動判定(初期値を登録)
        UserDefaults.standard.register(defaults: ["firstLaunch": true])
        
        // 新規バージョンでの初回起動判定
        UserDefaults.standard.register(defaults: ["ver1.4":false])
        
        // ユーザーIDを作成(初期値を登録)
        let uuid = NSUUID().uuidString
        UserDefaults.standard.register(defaults: ["userID":uuid])
        
        // アカウント持ちならFirebaseのユーザーIDを使用
        if let address = UserDefaults.standard.object(forKey: "address") as? String, let password = UserDefaults.standard.object(forKey: "password") as? String {
            // ログイン処理
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if error == nil {
                    // エラーなし
                } else {
                    // エラーのハンドリング
                    if AuthErrorCode(rawValue: error!._code) != nil {
                        return
                    }
                }
                // ログイン成功時の処理
                // FirebaseのユーザーIDを使用
                UserDefaults.standard.set(Auth.auth().currentUser!.uid, forKey: "userID")
            }
        }
        
        return true
    }
    
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

