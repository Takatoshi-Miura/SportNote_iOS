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
        let titleArray:[String]  = ["SportsNoteとは","課題の管理①","課題の管理②","ノートを作成","振り返り","課題を完了にする"]
        
        let detailArray:[String] = ["課題解決に特化したノートアプリです。\n原因と対策を考えて実践し、反省を通して、\n解決を目指すことができます。",
                                    "課題を一覧で管理できます。\nグループを作成することで課題を分類して\n管理することができます。",
                                    "課題毎に原因と対策を登録できます。\n優先度が最も高い対策が\nノートに読み込まれるようになります。",
                                    "練習ノートを作成できます。\nノートには登録した課題が読み込まれ、\n課題への取り組みを記録しておくことができます。",
                                    "記録した内容はノートで振り返ることができます。\n課題＞対策へと進めば、その課題への取り組み内容を\nまとめて振り返ることもできます。",
                                    "解決した課題は完了にすることで\nノートへ読み込まれなくなります。完了にしても\n完了した課題からいつでも振り返ることができます。"]
        
        let imageArray:[UIImage?] = [UIImage(named: "①SportsNoteとは"),UIImage(named: "②課題一覧"),UIImage(named: "③課題の管理"),
                                     UIImage(named: "④ノートを作成"),UIImage(named: "⑤振り返り"),UIImage(named: "⑥課題を完了にする")]
        
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
        button.frame = CGRect(x: UIScreen.main.bounds.maxX - 120, y: UIScreen.main.bounds.maxY - 60, width: 120, height: 60)
        self.view.addSubview(button)
    }
    
    // MARK: - Action
    
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
