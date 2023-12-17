//
//  NotePageViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/12/18.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol NotePageViewControllerDelegate: AnyObject {
    
}

class NotePageViewController: UIViewController {
    
    // MARK: - UI,Variable
    
    private let disposeBag = DisposeBag()
    var delegate: NotePageViewControllerDelegate?
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
    }
    
    /// リストビュー切替ボタンのバインド
    /// - Parameter button: ボタン
    private func bindListModeButton(button: UIBarButtonItem) {
        button.rx.tap
            .subscribe(onNext: { [unowned self] in
//                self.delegate?.noteVCNotePageDidTap(self)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// NavigationBar初期化
    private func initNavigationBar() {
        self.title = TITLE_NOTE
        let pageModeButton = UIBarButtonItem(image: UIImage(systemName: "book.pages"), style: .plain, target: self, action: nil)
        bindListModeButton(button: pageModeButton)
        navigationItem.rightBarButtonItems = [pageModeButton]
    }
    
}
