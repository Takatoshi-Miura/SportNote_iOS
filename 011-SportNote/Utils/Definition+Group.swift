//
//  Definition+Group.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/07/17.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

/// カラー
enum Color: Int, CaseIterable {
    case red
    case pink
    case orange
    case yellow
    case green
    case blue
    case purple
    case gray
    
    var title: String {
        switch self {
        case .red: return TITLE_RED
        case .pink: return TITLE_PINK
        case .orange: return TITLE_ORANGE
        case .yellow: return TITLE_YELLOW
        case .green: return TITLE_GREEN
        case .blue: return TITLE_BLUE
        case .purple: return TITLE_PURPLE
        case .gray: return TITLE_GRAY
        }
    }
    
    var color: UIColor {
        switch self {
        case .red: return UIColor.systemRed
        case .pink: return UIColor.systemPink
        case .orange: return UIColor.systemOrange
        case .yellow: return UIColor.systemYellow
        case .green: return UIColor.systemGreen
        case .blue: return UIColor.systemBlue
        case .purple: return UIColor.systemPurple
        case .gray: return UIColor.systemGray
        }
    }
}


/// ColorPickerの項目を取得
/// - Parameter element: Color
/// - Returns: 項目
func getColorPickerItems(element: Color) -> NSMutableAttributedString {
    // カラーイメージ
    let imageAttachment = NSTextAttachment()
    imageAttachment.image = UIImage(systemName: "circle.fill")?.withTintColor(element.color)
    imageAttachment.bounds = CGRect(x: 0, y: -5, width: 25, height: 25)
    let imageString = NSAttributedString(attachment: imageAttachment)
    // タイトル文字列
    let titleString = NSAttributedString(string: " \(element.title)", attributes: [
        .font: UIFont(name: "HiraKakuProN-W3", size: 18) ?? UIFont.systemFont(ofSize: 18)
    ])
    // 合体
    let fullString = NSMutableAttributedString()
    fullString.append(imageString)
    fullString.append(titleString)
    // 位置調整
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    fullString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: fullString.length))
    return fullString
}
