//
//  UtilsTests.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/08/07.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

@testable import _11_SportNote
import Testing
import Foundation

@Suite(.tags(.utils))
struct AppInfoTests {
    
    @Test("アプリバージョン確認")
    @available(iOS 15, *)
    func appVersion() async throws {
        let appVersion = AppInfo.getAppVersion()
        let appVersionStr = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        #expect(appVersion == appVersionStr)
    }
    
    @Test("ビルド番号確認")
    func buildNo() async throws {
        let buildNo = AppInfo.getBuildNo()
        let buildNoStr = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        #expect(buildNo == buildNoStr)
    }

}
