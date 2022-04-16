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
    var measuresViewController = MeasuresViewController()
//    let memoDetailCoordinator = MemoDetailCoordinator()
    
    func startFlow(in window: UIWindow?) {
    }
    
    func startFlow(in navigationController: UINavigationController) {
    }
    
    func startFrow(in navigationController: UINavigationController, withMeasures measures: Measures) {
        self.navigationController = navigationController
        measuresViewController = MeasuresViewController()
        measuresViewController.delegate = self
        measuresViewController.measures = measures
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
    
    // MeasuresVC → MemoDetailVC
    func measuresVCMemoDidTap(memo: Memo) {
//        memoDetailCoordinator.startFlow(in: navigationController!, withMemo: memo)
    }
    
}
