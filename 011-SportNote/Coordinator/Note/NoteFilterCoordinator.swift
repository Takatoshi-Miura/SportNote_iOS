//
//  NoteFilterCoordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/06/15.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class NoteFilterCoordinator: Coordinator {
    
    var navigationController: UINavigationController?
    var previousViewController: UIViewController?
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFlow(in viewController: UIViewController) {
        previousViewController = viewController
        let noteFilterViewController = NoteFilterViewController()
        noteFilterViewController.delegate = self
        if #available(iOS 13.0, *) {
            noteFilterViewController.isModalInPresentation = true
        }
        previousViewController!.present(noteFilterViewController, animated: true)
    }
    
}

extension NoteFilterCoordinator: NoteFilterViewControllerDelegate {
    
    // NoteVC ← NoteFilterVC
    func noteFilterVCCancelDidTap(_ viewController: NoteFilterViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // NoteVC ← NoteFilterVC
    func noteFilterVCApplyDidTap(_ viewController: NoteFilterViewController) {
        viewController.dismiss(animated: true, completion: nil)
//        (previousViewController as! NoteViewController).searchNoteWithFilter()
    }
    
}
