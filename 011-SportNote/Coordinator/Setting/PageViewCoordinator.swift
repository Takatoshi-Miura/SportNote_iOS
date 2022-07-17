//
//  PageViewCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/06/07.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class PageViewCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        let pageViewController = PageViewController()
        pageViewController.pageVCDelegate = self
        if #available(iOS 13.0, *) {
            pageViewController.isModalInPresentation = true
            pageViewController.modalPresentationStyle = .fullScreen
        }
        previousViewController!.present(pageViewController, animated: true)
    }
    
}

extension PageViewCoordinator: PageViewControllerDelegate {
    
    /// SettingVC ← PageVC
    func pageVCCancelDidTap(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
