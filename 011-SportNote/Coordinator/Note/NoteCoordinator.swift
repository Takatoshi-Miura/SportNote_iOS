//
//  NoteCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class NoteCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var noteViewController = NoteViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        noteViewController = NoteViewController()
        noteViewController.delegate = self
        navigationController.pushViewController(noteViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension NoteCoordinator: NoteViewControllerDelegate {
    
}

