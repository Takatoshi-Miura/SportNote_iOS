//
//  SettingViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/11/08.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel {
    
    // MARK: - Variable
    
    let cells: [[Cell]] = [[Cell.dataTransfer], [Cell.help, Cell.inquiry]]
    private let disposeBag = DisposeBag()
    
    enum Section: Int, CaseIterable {
        case data
        case help
        var title: String {
            switch self {
            case .data: return TITLE_DATA
            case .help: return TITLE_HELP
            }
        }
    }
    
    enum Cell: Int, CaseIterable {
        case dataTransfer
        case help
        case inquiry
        var title: String {
            switch self {
            case .dataTransfer: return TITLE_DATA_TRANSFER
            case .help: return TITLE_HOW_TO_USE_THIS_APP
            case .inquiry: return TITLE_INQUIRY
            }
        }
        var image: UIImage {
            switch self {
            case .dataTransfer: return UIImage(systemName: "icloud.and.arrow.up")!
            case .help: return UIImage(systemName: "questionmark.circle")!
            case .inquiry: return UIImage(systemName: "envelope")!
            }
        }
    }
    
    // MARK: - Initializer
    
    init() {
    }
    
    // MARK: - Other Methods
    
}
