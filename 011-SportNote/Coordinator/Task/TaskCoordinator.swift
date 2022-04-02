//
//  TaskCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/01.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var taskViewController = TaskViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        taskViewController = TaskViewController()
        taskViewController.delegate = self
        navigationController.pushViewController(taskViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension TaskCoordinator: TaskViewControllerDelegate {
    
}