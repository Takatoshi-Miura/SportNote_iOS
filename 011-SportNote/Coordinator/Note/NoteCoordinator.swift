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
    let freeNoteCoordinator = FreeNoteCoordinator()
    let addTargetCoordinator = AddTargetCoordinator()
    let addPracticeNoteCoordinator = AddPracticeNoteCoordinator()
    let addTournamentNoteCoordinator = AddTournamentNoteCoordinator()
    
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
    
    // NoteVC → AddPracticeNoteVC
    func noteVCAddPracticeNoteDidTap(_ viewController: UIViewController) {
        addPracticeNoteCoordinator.startFlow(in: viewController)
    }
    
    // NoteVC → AddTournamentNoteVC
    func noteVCAddTournamentNoteDidTap(_ viewController: UIViewController) {
        addTournamentNoteCoordinator.startFlow(in: viewController)
    }
    
    // NoteVC → FreeNoteVC
    func noteVCFreeNoteDidTap(freeNote: Note) {
        freeNoteCoordinator.startFrow(in: navigationController!, withFreeNote: freeNote)
    }
    
}

