//
//  TabBarController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/07.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // ノートタブを選択した状態で起動する
        selectedIndex = 1
    }

}
