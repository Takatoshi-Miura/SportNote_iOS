//
//  PageViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/08/07.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ViewControllerを配列に登録
        let VC1 = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        let VC2 = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        let VC3 = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        let VC4 = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        let VC5 = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        let VC6 = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        let VC7 = storyboard!.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        self.controllers = [VC1,VC2,VC3,VC4,VC5,VC6,VC7]
        
        // 各画面にチュートリアルデータを渡す
        for num in 0...self.controllers.count - 1 {
            let VC = self.controllers[num] as! TutorialViewController
            VC.titleText  = titleArray[num]
            VC.detailText = detailArray[num]
            VC.image = imageArray[num]!
        }
        
        // PageViewController初期化メソッド
        self.initPageViewController()

        // PageControlを追加
        self.addPageControl()
    }
    
    
    
    //MARK:- 変数の宣言
    
    // PageViewController関連
    var controllers: [UIViewController] = []
    var pageViewController: UIPageViewController!
    var pageControl: UIPageControl!
    
    // チュートリアルデータ
    var titleArray:[String]  = ["SportsNoteとは","課題の管理①","課題の管理②","ノートを作成","課題データと連動①","課題データと連動②","目標を設定"]
    var detailArray:[String] = ["課題解決に特化したノートアプリです。\n原因と対策を考えて実践し、練習後の反省を通して、\n解決を目指すことができます。",
                                "課題を一覧で管理できます。\n＋ボタンで課題を追加、右スワイプで解決済み、\n左スワイプで削除できます。",
                                "課題ごとに原因と対策を登録できます。\n「最有力の対策」に設定した対策は\nノートに読み込まれるようになります。",
                                "練習記録、大会記録を作成できます。\n作成したノートはノート一覧、\nまたはカレンダー画面で確認できます。",
                                "練習記録には未解決の課題が読み込まれます。\n「最有力の対策」の有効性を練習後に記入しましょう\nコメントを課題データに追記することもできます。",
                                "課題データに追記をした有効性コメントは\n課題データの対策画面に追加されます。\nタップで該当するノートを確認することもできます。",
                                "年間目標、月間目標を作成できます。\n設定した目標はノート一覧、\nまたはカレンダー画面で確認できます。",]
    var imageArray:[UIImage?] = [UIImage(named: "①概要"),UIImage(named: "②課題の管理"),UIImage(named: "②課題の管理"),
                                UIImage(named: "②課題の管理"),UIImage(named: "②課題の管理"),UIImage(named: "②課題の管理"),UIImage(named: "②課題の管理")]
    
    
    
    //MARK:- その他のメソッド
    
    // pageViewController初期化メソッド
    func initPageViewController() {
        // pageViewControllerの宣言
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.setViewControllers([self.controllers[0]], direction: .forward, animated: true, completion: nil)

        // デリゲート,データソースの指定
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
       
        // ビューを追加
        self.addChild(self.pageViewController)
        self.view.addSubview(self.pageViewController.view!)
    }
    
    // PageControlを追加するメソッド
    func addPageControl() {
        // PageControlの配置場所
        self.pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 60, width: UIScreen.main.bounds.width,height: 60))
        // 全ページ数
        self.pageControl.numberOfPages = self.controllers.count
        // 表示ページ
        self.pageControl.currentPage = 0
        // インジケータの色
        self.pageControl.pageIndicatorTintColor = .gray
        // 現在ページのインジケータの色
        self.pageControl.currentPageIndicatorTintColor = .white
        self.view.addSubview(self.pageControl)
    }
}



// MARK: - UIPageViewController DataSource
extension PageViewController: UIPageViewControllerDataSource {

    // ページ数
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.controllers.count
    }
   
    // 左にスワイプ（進む）
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.controllers.firstIndex(of: viewController),
            index < self.controllers.count - 1 {
            return self.controllers[index + 1]
        } else {
            return nil
        }
    }

    // 右にスワイプ （戻る）
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.controllers.firstIndex(of: viewController),
            index > 0 {
            return self.controllers[index - 1]
        } else {
            return nil
        }
    }
    
    // アニメーション終了後処理
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPage = pageViewController.viewControllers![0]
        self.pageControl.currentPage = self.controllers.firstIndex(of: currentPage)!
    }

}
