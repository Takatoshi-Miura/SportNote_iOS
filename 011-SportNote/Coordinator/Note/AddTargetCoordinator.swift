//
//  AddTargetCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/17.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddTargetCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var addTargetViewController = AddTargetViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        addTargetViewController = AddTargetViewController()
        addTargetViewController.delegate = self
        if #available(iOS 13.0, *) {
            addTargetViewController.isModalInPresentation = true
        }
        previousViewController!.present(addTargetViewController, animated: true)
    }
    
}

extension AddTargetCoordinator: AddTargetViewControllerDelegate {
    
    // NoteVC ← AddTargetVC
    func addTargetVCDismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // NoteVC ← AddTargetVC
    func addTargetVCDismissWithReload(_ viewController: UIViewController) {
        if previousViewController is NoteViewController {
            (previousViewController as! NoteViewController).tableView.reloadData()
        }
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
