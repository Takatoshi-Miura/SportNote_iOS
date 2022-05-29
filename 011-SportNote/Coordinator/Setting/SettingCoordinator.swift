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
    var settingViewController = SettingViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        settingViewController = SettingViewController()
        settingViewController.delegate = self
        if #available(iOS 13.0, *) {
            settingViewController.isModalInPresentation = true
        }
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
    
}
