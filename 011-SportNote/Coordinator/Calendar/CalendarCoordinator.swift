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
        let addTargetCoordinator = AddTargetCoordinator()
        addTargetCoordinator.startFlow(in: viewController)
    }
    
    // CalendarVC → PracticeNoteVC
    func calendarVCPracticeNoteDidTap(practiceNote: Note) {
        let addPracticeNoteCoordinator = AddPracticeNoteCoordinator()
        addPracticeNoteCoordinator.startFrow(in: navigationController!, withNote: practiceNote)
    }
    
    // CalendarVC → TournamentNoteVC
    func calendarVCTournamentNoteDidTap(tournamentNote: Note) {
        let addTournamentNoteCoordinator = AddTournamentNoteCoordinator()
        addTournamentNoteCoordinator.startFrow(in: navigationController!, withNote: tournamentNote)
    }
    
}
