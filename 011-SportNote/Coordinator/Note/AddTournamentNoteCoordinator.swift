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
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withNote note: Note) {
        // Viewer
        self.navigationController = navigationController
        let addTournamentNoteViewController = AddTournamentNoteViewController()
        addTournamentNoteViewController.delegate = self
        addTournamentNoteViewController.realmNote = note
        addTournamentNoteViewController.isViewer = true
        addTournamentNoteViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(addTournamentNoteViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
        // 新規作成
        previousViewController = viewController
        let addTournamentNoteViewController = AddTournamentNoteViewController()
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
    
    // NoteVC ← AddTournamentNoteVC
    func addTournamentNoteVCAddNote(_ viewController: UIViewController) {
        (previousViewController as! NoteViewController).refreshData()
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // NoteVC ← AddTournamentNoteVC
    func addTournamentNoteVCDeleteNote() {
        navigationController?.popViewController(animated: true)
    }
    
}
