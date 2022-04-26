//
//  AddPracticeNoteCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/27.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddPracticeNoteCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var addPracticeNoteViewController = AddPracticeNoteViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        addPracticeNoteViewController = AddPracticeNoteViewController()
        addPracticeNoteViewController.delegate = self
        if #available(iOS 13.0, *) {
            addPracticeNoteViewController.isModalInPresentation = true
        }
        previousViewController!.present(addPracticeNoteViewController, animated: true)
    }
    
}

extension AddPracticeNoteCoordinator: AddPracticeNoteViewControllerDelegate {
    
    // NoteVC ← AddPracticeNoteVC
    func addPracticeNoteVCDismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
