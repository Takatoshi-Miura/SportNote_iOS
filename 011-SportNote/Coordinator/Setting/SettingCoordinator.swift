//
//  SettingCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/22.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class SettingCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        let settingViewController = SettingViewController()
        settingViewController.delegate = self
        previousViewController!.present(settingViewController, animated: true)
    }
    
}

extension SettingCoordinator: SettingViewControllerDelegate {
    
    /// TaskVC ← SettingVC
    func settingVCCancelDidTap(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    /// SettingVC → LoginVC
    func settingVCDataTransferDidTap(_ viewController: UIViewController) {
        let loginCoordinator = LoginCoordinator()
        loginCoordinator.startFlow(in: viewController)
    }
    
    /// SettingVC → TutorialVC
    func settingVCTutorialDidTap(_ viewController: UIViewController) {
        let pageViewCoordinator = PageViewCoordinator()
        pageViewCoordinator.startFlow(in: viewController)
    }
    
}
