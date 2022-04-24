//
//  CalendarCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/03.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class CalendarCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var calendarViewController = CalendarViewController()
    let addTargetCoordinator = AddTargetCoordinator()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        calendarViewController = CalendarViewController()
        calendarViewController.delegate = self
        navigationController.pushViewController(calendarViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension CalendarCoordinator: CalendarViewControllerDelegate {
    
    // CalendarVC → AddTargetVC
    func calendarVCAddTargetDidTap(_ viewController: UIViewController) {
        addTargetCoordinator.startFlow(in: viewController)
    }
    
}
