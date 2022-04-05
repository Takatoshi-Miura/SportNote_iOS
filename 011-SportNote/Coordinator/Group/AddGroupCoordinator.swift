//
//  AddGroupCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/05.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddGroupCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var addGroupViewController = AddGroupViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        addGroupViewController = AddGroupViewController()
        addGroupViewController.delegate = self
        if #available(iOS 13.0, *) {
            addGroupViewController.isModalInPresentation = true
        }
        previousViewController!.present(addGroupViewController, animated: true)
    }
    
}

extension AddGroupCoordinator: AddGroupViewControllerDelegate {
    
    // TaskVC ← AddGroupVC
    func addGroupVCDismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
