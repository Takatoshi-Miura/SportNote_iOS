//
//  LoginCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/30.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class LoginCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        if #available(iOS 13.0, *) {
            loginViewController.isModalInPresentation = true
        }
        previousViewController!.present(loginViewController, animated: true)
    }
    
}

extension LoginCoordinator: LoginViewControllerDelegate {
    
    /// SettingVC ← LoginVC
    func loginVCUserDidLogin(_ viewController: UIViewController) {
        viewController.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "afterLogin"), object: nil)
        })
    }
    
    /// SettingVC ← LoginVC
    func loginVCUserDidLogout(_ viewController: UIViewController) {
        viewController.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "afterLogout"), object: nil)
        })
    }
    
    /// SettingVC ← LoginVC
    func loginVCCancelDidTap(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
