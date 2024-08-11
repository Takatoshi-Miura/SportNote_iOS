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

@Suite(.tags(.date))
struct DateTests {
    
    private let year: Int
    private let month: Int
    private let day: Int
    
    init() {
        year = 2024
        month = 1
        day = 20
    }
    
    @Test("時刻文字列に変換")
    func testFormatDate() {
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(year: year, month: month, day: day)
        let testDate = calendar.date(from: dateComponents)!
        let resultString = formatDate(date: testDate, format: "yyyy-MM-dd HH:mm:ss")
        
        let expectedString = "2024-01-20 00:00:00"
        
        #expect(resultString == expectedString)
    }
    
    @Test("年月日文字列からDate型に変換")
    func testConvertToDate() {
        let resultDate = convertToDate(year: year, month: month, date: day)
        
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(year: year, month: month, day: day)
        let expectedDate = calendar.date(from: dateComponents)
        
        #expect(resultDate == expectedDate)
    }
    
}
