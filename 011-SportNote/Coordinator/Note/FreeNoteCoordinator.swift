//
//  FreeNoteCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/23.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class FreeNoteCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withFreeNote freeNote: Note) {
        self.navigationController = navigationController
        let freeNoteViewController = FreeNoteViewController(freeNote: freeNote)
        freeNoteViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(freeNoteViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}
