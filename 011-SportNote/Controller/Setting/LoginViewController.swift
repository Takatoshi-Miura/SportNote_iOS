//
//  LoginViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/30.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordChangeButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action
    
    @IBAction func tapLoginButton(_ sender: Any) {
    }
    
    @IBAction func tapPasswordChangeButton(_ sender: Any) {
    }
    
    @IBAction func tapCreateAccountButton(_ sender: Any) {
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
    }
    
}

