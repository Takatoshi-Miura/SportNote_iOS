//
//  AppCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/01.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {
    
    var window: UIWindow?
    var tabCoordinator: TabCoordinator?
    
    func startFlow(in window: UIWindow?) {
        self.window = window
        tabCoordinator = TabCoordinator()
        tabCoordinator?.startFlow(in: window)
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension UIWindow {
    
    public func change(rootViewController: UIViewController, WithAnimation animation: Bool) {
        self.rootViewController = nil
        self.rootViewController = rootViewController
        rootViewController.view.alpha = animation ? 0 : 1
        makeKeyAndVisible()
        guard animation else { return }
        UIView.animate(withDuration: 0.3) { rootViewController.view.alpha = 1 }
    }
    
}
