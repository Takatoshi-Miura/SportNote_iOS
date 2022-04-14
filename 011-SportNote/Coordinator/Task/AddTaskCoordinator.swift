//
//  AddTaskCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/15.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddTaskCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var addTaskViewController = AddTaskViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        addTaskViewController = AddTaskViewController()
        addTaskViewController.delegate = self
        if #available(iOS 13.0, *) {
            addTaskViewController.isModalInPresentation = true
        }
        previousViewController!.present(addTaskViewController, animated: true)
    }
    
}

extension AddTaskCoordinator: AddTaskViewControllerDelegate {
    
    // TaskVC ← AddTaskVC
    func addTaskVCDismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
