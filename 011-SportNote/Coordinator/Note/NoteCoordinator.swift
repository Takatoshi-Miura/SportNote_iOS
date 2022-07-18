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
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
        self.navigationController = navigationController
        let noteViewController = NoteViewController()
        noteViewController.delegate = self
        navigationController.pushViewController(noteViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension NoteCoordinator: NoteViewControllerDelegate {
    
    // NoteVC → AddPracticeNoteVC
    func noteVCAddPracticeNoteDidTap(_ viewController: UIViewController) {
        let addPracticeNoteCoordinator = AddPracticeNoteCoordinator()
        addPracticeNoteCoordinator.startFlow(in: viewController)
    }
    
    // NoteVC → AddTournamentNoteVC
    func noteVCAddTournamentNoteDidTap(_ viewController: UIViewController) {
        let addTournamentNoteCoordinator = AddTournamentNoteCoordinator()
        addTournamentNoteCoordinator.startFlow(in: viewController)
    }
    
    // NoteVC → FreeNoteVC
    func noteVCFreeNoteDidTap(freeNote: Note) {
        let freeNoteCoordinator = FreeNoteCoordinator()
        freeNoteCoordinator.startFrow(in: navigationController!, withFreeNote: freeNote)
    }
    
    // NoteVC → PracticeNoteVC
    func noteVCPracticeNoteDidTap(practiceNote: Note) {
        let addPracticeNoteCoordinator = AddPracticeNoteCoordinator()
        addPracticeNoteCoordinator.startFrow(in: navigationController!, withNote: practiceNote)
    }
    
    // NoteVC → TournamentNoteVC
    func noteVCTournamentNoteDidTap(tournamentNote: Note) {
        let addTournamentNoteCoordinator = AddTournamentNoteCoordinator()
        addTournamentNoteCoordinator.startFrow(in: navigationController!, withNote: tournamentNote)
    }
    
    // NoteVC → NoteFilterVC
    func noteVCFilterDidTap(_ viewController: UIViewController) {
        let noteFilterCoordinator = NoteFilterCoordinator()
        noteFilterCoordinator.startFlow(in: viewController)
    }
    
}

