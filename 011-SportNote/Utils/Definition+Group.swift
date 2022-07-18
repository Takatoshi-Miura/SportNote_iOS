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
