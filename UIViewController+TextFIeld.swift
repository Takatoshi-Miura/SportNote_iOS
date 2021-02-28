//
//  UIViewController+TextFIeld.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2021/02/28.
//  Copyright © 2021 Takatoshi Miura. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    // MARK: Public Methods
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}
