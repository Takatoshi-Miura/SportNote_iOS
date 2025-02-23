//
//  UIViewController+PickerView.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2021/02/28.
//  Copyright © 2021 Takatoshi Miura. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    /**
     PickerViewを画面下から出現
     - Parameters:
        - pickerView: PickerVIewを載せたUIView
        - isModal: モーダル表示かどうか
     */
    func openPicker(_ pickerView: UIView, isModal: Bool) {
        view.addSubview(pickerView)
        pickerView.frame.origin.y = UIScreen.main.bounds.size.height
        let bottomPadding: CGFloat = 40
        UIView.animate(withDuration: 0.3) {
            if isModal {
                pickerView.frame.origin.y = UIScreen.main.bounds.size.height - pickerView.bounds.size.height - bottomPadding
            } else {
                pickerView.frame.origin.y = UIScreen.main.bounds.size.height - pickerView.bounds.size.height
            }
        }
    }
    
    /**
     PickerViewを閉じる
     - Parameters:
        - pickerView: PickerVIewを載せたUIView
     */
    func closePicker(_ pickerView:UIView) {
        UIView.animate(withDuration: 0.3) {
            pickerView.frame.origin.y += pickerView.bounds.size.height
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            pickerView.removeFromSuperview()
        }
    }
    
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
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44)
        // ボタン作成＆セット
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: doneAction)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: cancelAction)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([cancelItem,flexibleItem,doneItem], animated: true)
        // 作成したツールバーを返却
        return toolbar
    }
    
    /**
     ツールバーを作成(完了ボタン)
     - Parameters:
        - doneAction: 完了ボタンの処理
     - Returns: ツールバー
     */
    func createToolBar(_ doneAction: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44)
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: doneAction)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleItem, doneItem], animated: true)
        
        return toolbar
    }
    
    /**
     PickerViewを画面下から出現(スクロール有)
     - Parameters:
        - pickerView: PickerVIewを載せたUIView
        - scrollPosition: 現在のスクロール位置
        - bottomPadding: SafeArea外の余白
     */
    func openPicker(_ pickerView:UIView, _ scrollPosition:CGFloat, _ bottomPadding:CGFloat) {
        let toolbarHeight:CGFloat = 44
        pickerView.frame.origin.y = scrollPosition
        UIView.animate(withDuration: 0.3) {
            pickerView.frame.origin.y = scrollPosition - pickerView.bounds.size.height - toolbarHeight - bottomPadding
        }
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
    
    /// DatePickerから日付を取得
    /// - Parameters:
    ///   - datePicker: UIDatePicker
    ///   - format: 文字列フォーマット yyyy/M/d (E)等
    /// - Returns: フォーマットに変換された日付文字列
    func getDatePickerDate(datePicker: UIDatePicker, format: String) -> String {
        return formatDate(date: datePicker.date, format: format)
    }

}
