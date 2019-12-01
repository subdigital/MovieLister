//
//  LoginViewController.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/10/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit
import SimpleNetworking
import SafariServices

class LoginViewController : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        World.sessionManager.startLogin(from: self)
    }
}
