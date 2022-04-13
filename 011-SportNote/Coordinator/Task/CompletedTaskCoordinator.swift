//
//  CompletedTaskCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/12.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class CompletedTaskCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var completedTaskViewController = CompletedTaskViewController()
    let taskDetailCoordinator = TaskDetailCoordinator()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withGroupID groupID: String) {
        self.navigationController = navigationController
        completedTaskViewController = CompletedTaskViewController()
        completedTaskViewController.delegate = self
        completedTaskViewController.groupID = groupID
        navigationController.pushViewController(completedTaskViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}


extension CompletedTaskCoordinator: CompletedTaskViewControllerDelegate {
    
    // CompletedTaskVC → TaskDetailVC
    func completedTaskVCTaskCellDidTap(task: Task) {
        taskDetailCoordinator.startFrow(in: navigationController!, withTask: task)
    }
    
}
