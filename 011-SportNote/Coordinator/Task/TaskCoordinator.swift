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
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in navigationController: UINavigationController, isCompleted: Bool, groupID: String) {
        self.navigationController = navigationController
        let taskViewController = TaskViewController()
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
        let addGroupCoordinator = AddGroupCoordinator()
        addGroupCoordinator.startFlow(in: viewController)
    }
    
    // TaskVC → AddTaskVC
    func taskVCAddTaskDidTap(_ viewController: UIViewController) {
        let addTaskCoordinator = AddTaskCoordinator()
        addTaskCoordinator.startFlow(in: viewController)
    }
    
    // TaskVC → GroupVC
    func taskVCHeaderDidTap(group: Group) {
        let groupCoordinator = GroupCoordinator()
        groupCoordinator.startFrow(in: navigationController!, withGroup: group)
    }
    
    // TaskVC → TaskDetailVC
    func taskVCTaskCellDidTap(task: Task) {
        let taskDetailCoordinator = TaskDetailCoordinator()
        taskDetailCoordinator.startFrow(in: navigationController!, withTask: task)
    }
    
    // TaskVC → CompletedTaskVC
    func taskVCCompletedTaskCellDidTap(groupID: String) {
        let taskCoordinator = TaskCoordinator()
        taskCoordinator.startFlow(in: navigationController!, isCompleted: true, groupID: groupID)
    }
    
    // TaskVC → SettingVC
    func taskVCSettingDidTap(_ viewController: UIViewController) {
        let settingCoordinator = SettingCoordinator()
        settingCoordinator.startFlow(in: viewController)
    }
    
    // TaskVC → TutorialVC
    func taskVCShowTutorial(_ viewController: UIViewController) {
        let pageViewCoordinator = PageViewCoordinator()
        pageViewCoordinator.startFlow(in: viewController)
    }
    
}
