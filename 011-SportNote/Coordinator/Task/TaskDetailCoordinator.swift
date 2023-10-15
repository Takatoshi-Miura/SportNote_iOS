//
//  TaskDetailCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/14.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskDetailCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withTask task: Task) {
        self.navigationController = navigationController
        let taskDetailViewController = TaskDetailViewController(task: task)
        taskDetailViewController.delegate = self
        navigationController.pushViewController(taskDetailViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}


extension TaskDetailCoordinator: TaskDetailViewControllerDelegate {
    
    // TaskVC ← TaskDetailVC
    func taskDetailVCCompleteTask(task: Task) {
        navigationController?.popToRootViewController(animated: true)
        let taskVC = navigationController?.topViewController as! TaskViewController
        if !task.isComplete {
            taskVC.insertTask(task: task)
        }
    }
    
    // TaskVC ← TaskDetailVC
    // CompleteTaskVC ← TaskDetailVC
    func taskDetailVCDeleteTask(task: Task) {
        navigationController?.popViewController(animated: true)
    }
    
    // TaskDetailVC → MeasuresVC
    func taskDetailVCMeasuresCellDidTap(measures: Measures) {
        let measuresCoordinator = MeasuresCoordinator()
        measuresCoordinator.startFrow(in: navigationController!, withMeasures: measures)
    }
    
}
