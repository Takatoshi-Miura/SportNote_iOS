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
    var loginViewController = LoginViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        loginViewController = LoginViewController()
//        loginViewController.delegate = self
        if #available(iOS 13.0, *) {
            loginViewController.isModalInPresentation = true
        }
        previousViewController!.present(loginViewController, animated: true)
    }
    
}
