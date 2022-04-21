//
//  AddTournamentNoteCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/18.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddTournamentNoteCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    var addTournamentNoteViewController = AddTournamentNoteViewController()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        addTournamentNoteViewController = AddTournamentNoteViewController()
        addTournamentNoteViewController.delegate = self
        if #available(iOS 13.0, *) {
            addTournamentNoteViewController.isModalInPresentation = true
        }
        previousViewController!.present(addTournamentNoteViewController, animated: true)
    }
    
}

extension AddTournamentNoteCoordinator: AddTournamentNoteViewControllerDelegate {
    
    // NoteVC ← AddTournamentNoteVC
    func addTournamentNoteVCDismiss(_ viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
