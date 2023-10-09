//
//  LocalizedLabel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/09.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import UIKit

@IBDesignable class LocalizedLabel: UILabel {
    @IBInspectable var localizedText: String {
        set(key) {
            let textComps: [String] = key.components(separatedBy: ".")
            self.text = NSLocalizedString(textComps[1], tableName: textComps[0], comment: "")
        }
        get {
            return text!
        }
    }
}

