//
//  AppInfo.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/05/12.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

import Foundation

final class AppInfo {

    /// アプリバージョンを取得
    /// - Returns: バージョン番号（例：1.0.0）
    static func getAppVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    /// ビルド番号を取得
    /// - Returns: ビルド番号
    static func getBuildNo() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

}
