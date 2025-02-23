//
//  MeasuresCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/16.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class MeasuresCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withMeasures measures: Measures) {
        self.navigationController = navigationController
        let measuresViewController = MeasuresViewController(measures: measures)
        measuresViewController.delegate = self
        measuresViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(measuresViewController, animated: true)
    }
    
    func startFlow(in viewController: UIViewController) {
    }
    
}

extension MeasuresCoordinator: MeasuresViewControllerDelegate {
    
    // TaskDetailVC ← MeasuresVC
    func measuresVCDeleteMeasures() {
        navigationController?.popViewController(animated: true)
    }
    
    // MeasuresVC → PracticeNoteVC
    func measuresVCMemoDidTap(memo: Memo) {
        let realmManager = RealmManager()
        let practiceNote = realmManager.getNote(ID: memo.noteID)
        let addPracticeNoteCoordinator = AddPracticeNoteCoordinator()
        addPracticeNoteCoordinator.startFrow(in: navigationController!, withNote: practiceNote)
    }
    
}
