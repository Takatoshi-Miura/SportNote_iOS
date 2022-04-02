//
//  TabCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/01.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

enum TabBarPage {
    
    case task
    case note

    init?(index: Int) {
        switch index {
        case 0:
            self = .task
        case 1:
            self = .note
        default:
            return nil
        }
    }
    
    /// タイトルを返却
    /// - Returns: タイトル文字列
    func pageTitleValue() -> String {
        switch self {
        case .task:
            return TITLE_TASK
        case .note:
            return TITLE_NOTE
        }
    }
    
    /// 並び順を返却
    /// - Returns: 並び順
    func pageOrderNumber() -> Int {
        switch self {
        case .task:
            return 0
        case .note:
            return 1
        }
    }
    
    /// タブのアイコン画像を返却
    /// - Returns: アイコン画像
    func pageTabIcon() -> UIImage {
        switch self {
        case .task:
            return UIImage(systemName: "list.bullet.indent")!
        case .note:
            return UIImage(systemName: "book")!
        }
    }
    
}


protocol TabCoordinatorProtocol: Coordinator {
    
    var tabBarController: UITabBarController { get set }
    
    func selectPage(_ page: TabBarPage)
    
    func setSelectedIndex(_ index: Int)
    
    func currentPage() -> TabBarPage?
    
}


class TabCoordinator: NSObject, Coordinator {
    
    var tabBarController: UITabBarController
    let taskCoordinator = TaskCoordinator()
    let noteCoordinator = NoteCoordinator()
    
    required override init() {
        self.tabBarController = .init()
    }
    
    func startFlow(in window: UIWindow?) {
        let pages: [TabBarPage] = [.note, .task]
            .sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
        let controllers: [UINavigationController] = pages.map({ getTabController($0) })
        prepareTabBarController(withTabControllers: controllers)
        window?.change(rootViewController: tabBarController, WithAnimation: true)
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
    /// TabBarControllerに含まれるViewControllerを取得
    /// - Parameters:
    ///    - page: ページ番号
    /// - Returns: ViewController(NavigationController配下)
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        // NavigationController生成
        let navController = UINavigationController()
        navController.setNavigationBarHidden(false, animated: false)
        navController.tabBarItem = UITabBarItem.init(title: page.pageTitleValue(),
                                                     image: page.pageTabIcon(),
                                                     tag: page.pageOrderNumber())
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            appearance.backgroundEffect = UIBlurEffect(style: .light)
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
        }
        
        switch page {
        case .task:
            taskCoordinator.startFlow(in: navController)
        case .note:
            noteCoordinator.startFlow(in: navController)
        }
        
        return navController
    }
    
    func currentPage() -> TabBarPage? {
        TabBarPage.init(index: tabBarController.selectedIndex)
    }

    func selectPage(_ page: TabBarPage) {
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
    
    func setSelectedIndex(_ index: Int) {
        guard let page = TabBarPage.init(index: index) else { return }
        tabBarController.selectedIndex = page.pageOrderNumber()
    }
    
    /// TabBarControllerの初期設定
    /// - Parameters:
    ///    - withTabControllers: TabBarに含めるViewController
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.delegate = self
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.task.pageOrderNumber()
        tabBarController.tabBar.isTranslucent = false
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
}

extension TabCoordinator: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(tabBarController.selectedIndex)
    }
    
}


