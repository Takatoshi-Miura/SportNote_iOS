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
    let addGroupCoordinator = AddGroupCoordinator()
    let addTaskCoordinator = AddTaskCoordinator()
    let groupCoordinator = GroupCoordinator()
    let taskDetailCoordinator = TaskDetailCoordinator()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in navigationController: UINavigationController, isCompleted: Bool, groupID: String) {
        self.navigationController = navigationController
        taskViewController = TaskViewController()
        taskViewController.delegate = self
        taskViewController.isCompleted = isCompleted
        taskViewController.groupID = groupID
        navigationController.pushViewController(taskViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension TaskCoordinator: TaskViewControllerDelegate {
    
    // TaskVC → AddGroupVC
    func taskVCAddGroupDidTap(_ viewController: UIViewController) {
        addGroupCoordinator.startFlow(in: viewController)
    }
    
    // TaskVC → AddTaskVC
    func taskVCAddTaskDidTap(_ viewController: UIViewController) {
        addTaskCoordinator.startFlow(in: viewController)
    }
    
    // TaskVC → GroupVC
    func taskVCHeaderDidTap(group: Group) {
        groupCoordinator.startFrow(in: navigationController!, withGroup: group)
    }
    
    // TaskVC → TaskDetailVC
    func taskVCTaskCellDidTap(task: Task) {
        taskDetailCoordinator.startFrow(in: navigationController!, withTask: task)
    }
    
    // TaskVC → CompletedTaskVC
    func taskVCCompletedTaskCellDidTap(groupID: String) {
        let taskCoordinator = TaskCoordinator()
        taskCoordinator.startFlow(in: navigationController!, isCompleted: true, groupID: groupID)
    }
    
}
