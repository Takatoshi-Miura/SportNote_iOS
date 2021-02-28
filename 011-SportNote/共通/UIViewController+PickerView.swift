//
//  UIViewController+PickerView.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2021/02/28.
//  Copyright © 2021 Takatoshi Miura. All rights reserved.
//

import UIKit

public extension UIViewController {

    // MARK: Public Methods
    
    /**
     ツールバーを作成(キャンセル、完了ボタン)
     - Parameters:
        - doneAction: 完了ボタンの処理
        - cancelAction: キャンセルボタンの処理
     - Returns: ツールバー
     */
    func createToolBar(_ doneAction:Selector, _ cancelAction:Selector) -> UIToolbar {
        // ツールバーを作成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        // ボタン作成＆セット
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: doneAction)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: cancelAction)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        // 作成したツールバーを返却
        return toolbar
    }
    
    /**
     ツールバーを作成(完了ボタン名指定)
     - Parameters:
        - doneName: 完了ボタンに表示される文字列
        - doneAction: 完了ボタンの処理
        - cancelAction: キャンセルボタンの処理
     - Returns: ツールバー
     */
    func createToolBar(_ doneName:String ,_ doneAction:Selector, _ cancelAction:Selector) -> UIToolbar {
        // ツールバーを作成
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        // ボタン作成＆セット
        let doneItem = UIBarButtonItem(title: doneName, style: UIBarButtonItem.Style.done, target: self, action: doneAction)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: cancelAction)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        // 作成したツールバーを返却
        return toolbar
    }

}
