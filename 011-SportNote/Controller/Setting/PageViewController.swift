//
//  PageViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/06/07.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate: AnyObject {
    // キャンセルタップ時の処理
    func pageVCCancelDidTap(_ viewController: UIViewController)
}

class PageViewController: UIPageViewController {
    
    // MARK: - UI,Variable
    private var controllers: [UIViewController] = []
    private var pageControl: UIPageControl!
    var pageVCDelegate: PageViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initPageView()
    }
    
    /// PageView初期化
    private func initPageView() {
        // チュートリアル画面を追加
        let titleArray:[String]  = ["SportsNoteとは","課題の管理①","課題の管理②","ノートを作成","課題データと連動①","課題データと連動②","目標を設定"]
        
        let detailArray:[String] = ["課題解決に特化したノートアプリです。\n原因と対策を考えて実践し、反省を通して、\n解決を目指すことができます。",
                                    "課題を一覧で管理できます。\n＋ボタンで課題を追加、左右のスワイプで\n解決済みや削除ができます。",
                                    "課題ごとに原因と対策を登録できます。\n「最有力の対策」に設定した対策は\nノートに読み込まれるようになります。",
                                    "練習記録、大会記録を作成できます。\n作成したノートはノート一覧、\nまたはカレンダー画面で確認できます。",
                                    "練習記録には未解決の課題が表示されます。\n「最有力の対策」の有効性を記録できます。\nコメントを課題データにも追記できます。",
                                    "課題データに追記した有効性コメントは\n課題の対策画面に追加されます。\nタップで該当するノートを確認できます。",
                                    "年間目標、月間目標を作成できます。\n設定した目標はノート一覧、\nまたはカレンダー画面で確認できます。"]
        
        let imageArray:[UIImage?] = [UIImage(named: "①概要"),UIImage(named: "②課題の管理"),UIImage(named: "③課題の管理"),
                                     UIImage(named: "④ノート追加"),UIImage(named: "⑤課題と連動"),UIImage(named: "⑥課題と連動"),UIImage(named: "⑦目標設定")]
        
        for index in 0...titleArray.count - 1 {
            let tutorialVC = TutorialViewController()
            tutorialVC.initView(title: titleArray[index], detail: detailArray[index], image: imageArray[index]!)
            self.controllers.append(tutorialVC)
        }
        
        // pageViewController追加
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.setViewControllers([self.controllers[0]], direction: .forward, animated: true, completion: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        self.addChild(pageViewController)
        self.view.addSubview(pageViewController.view!)
        
        // pageControl追加
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 60, width: UIScreen.main.bounds.width,height: 60))
        pageControl.numberOfPages = self.controllers.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(self.pageControl)
        
        // キャンセルボタン追加
        let button = UIButton()
        button.addTarget(self, action: #selector(tapCloseButton(_:)), for: UIControl.Event.touchUpInside)
        button.setTitle(TITLE_CANCEL, for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.frame = CGRect(x: UIScreen.main.bounds.maxX - 80, y: UIScreen.main.bounds.maxY - 60, width: 80, height: 60)
        self.view.addSubview(button)
    }
    
    /// キャンセルボタンの処理
    @objc func tapCloseButton(_ sender: UIButton) {
        pageVCDelegate?.pageVCCancelDidTap(self)
    }
    
}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
