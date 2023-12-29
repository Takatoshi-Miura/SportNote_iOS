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
    // リスト切替ボタンタップ時
    func notePageVCListDidTap(_ viewController: UIViewController)
}

class NotePageViewController: UIPageViewController {
    
    // MARK: - UI,Variable
    
    private var controllers: [UIViewController] = []
    private var pageControl: UIPageControl!
    private var viewModel = NotePageViewModel()
    private let disposeBag = DisposeBag()
    var notePageVCdelegate: NotePageViewControllerDelegate?
    
    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initNoteDetailView()
        initPageVC()
        initPageControl()
    }
    
    // MARK: - Bind
    
    /// リストビュー切替ボタンのバインド
    /// - Parameter button: ボタン
    private func bindListModeButton(button: UIBarButtonItem) {
        button.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.notePageVCdelegate?.notePageVCListDidTap(self)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// NavigationBar初期化
    private func initNavigationBar() {
        self.title = TITLE_NOTE
        self.navigationItem.hidesBackButton = true
        let listModeButton = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: nil)
        bindListModeButton(button: listModeButton)
        navigationItem.rightBarButtonItems = [listModeButton]
    }
    
    /// ノート詳細画面作成
    private func initNoteDetailView() {
        for note in viewModel.noteArray.value {
            let noteDetailVC = NoteDetailViewController(note: note)
            self.controllers.append(noteDetailVC)
        }
    }
    
    /// PageViewController初期化
    private func initPageVC() {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.setViewControllers([self.controllers[0]], direction: .forward, animated: true, completion: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        self.addChild(pageViewController)
        
        // NavigationBarの下に隠れないようにMarginを確保
        let topMargin = navigationController?.navigationBar.frame.maxY ?? 0
        pageViewController.view.frame = CGRect(x: 0, y: topMargin, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topMargin)
        self.view.addSubview(pageViewController.view!)
    }
    
    /// pageControl初期化
    private func initPageControl() {
        let bottomMargin = tabBarController?.tabBar.frame.height ?? 0
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - bottomMargin - 30, width: UIScreen.main.bounds.width,height: 30))
        pageControl.numberOfPages = self.controllers.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(self.pageControl)
    }
    
}

extension NotePageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    /// ページ数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }
   
    /// 左にスワイプ（進む）
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController), index < controllers.count - 1 {
            return controllers[index + 1]
        } else {
            return nil
        }
    }

    /// 右にスワイプ （戻る）
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = controllers.firstIndex(of: viewController), index > 0 {
            return controllers[index - 1]
        } else {
            return nil
        }
    }
    
    /// アニメーション終了後処理
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPage = pageViewController.viewControllers![0]
        pageControl.currentPage = controllers.firstIndex(of: currentPage)!
    }

}
