//
//  Coordinator.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/01.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    
    func startFlow(in window: UIWindow?)
    
    func startFlow(in navigationController: UINavigationController)
    
    func startFlow(in viewController: UIViewController)
    
}
