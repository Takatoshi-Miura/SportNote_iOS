//
//  GroupCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/11.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class GroupCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withGroup group: Group) {
        self.navigationController = navigationController
        let groupViewController = GroupViewController(group: group)
        groupViewController.delegate = self
        groupViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(groupViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension GroupCoordinator: GroupViewControllerDelegate {
    
    // TaskVC ← GroupVC
    func groupVCDeleteGroup() {
        navigationController?.popViewController(animated: true)
    }
    
}
