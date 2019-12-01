//
//  AccountViewController.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/10/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit
import SimpleNetworking

class AccountViewController : UIViewController {
 
    @IBOutlet private weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = "..."
        fetchAccount()
    }
    
    @IBAction private func logOut() {
        SessionManager.shared.logOut()
    }
    
    private func fetchAccount() {
        MovieDB.api.send(request: .account({ result in
            switch result {
            case .success(let account):
                self.usernameLabel.text = account.displayName

            case .failure(let error):
                let alert = UIAlertController(title: "Error fetching account", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
    }
}
