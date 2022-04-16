//
//  AppDelegate.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/23.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Google AdMob初期化
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Realmファイルの場所
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // 初回起動判定(初期値を登録)
        UserDefaults.standard.register(defaults: ["firstLaunch": true])
        
        // ユーザーIDを作成(初期値を登録)
        let uuid = "fXaDuDnAlJfJpErw555wEDJMwZ72"//NSUUID().uuidString
        UserDefaults.standard.register(defaults: ["userID":uuid])
        
        // アカウント持ちならFirebaseのユーザーIDを使用
        if let address = UserDefaults.standard.object(forKey: "address") as? String,
           let password = UserDefaults.standard.object(forKey: "password") as? String
        {
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
        
        // 初期画面を表示
        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator()
        appCoordinator?.startFlow(in: window)
        
        return true
    }

}

