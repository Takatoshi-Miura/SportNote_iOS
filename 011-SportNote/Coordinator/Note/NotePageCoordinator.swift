//
//  NotePageCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/12/18.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import UIKit

class NotePageCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        let notePageViewController = NotePageViewController()
        notePageViewController.delegate = self
        navigationController.pushViewController(notePageViewController, animated: false)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension NotePageCoordinator: NotePageViewControllerDelegate {
    
    // NotePageVC → NoteVC
    func notePageVCListDidTap(_ viewController: UIViewController) {
        navigationController?.popViewController(animated: false)
    }
    
}
