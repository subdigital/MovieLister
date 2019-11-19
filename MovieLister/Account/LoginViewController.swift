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
//        MovieDB.api.send(request: .createRequestToken()) { (result: Result<AuthenticationTokenResponse, APIError>) in
//            switch result {
//            case .success(let response):
//                self.authorizeRequestToken(response.requestToken)
//
//            case .failure(let error):
//                let alert = UIAlertController(title: "Error fetching request token",
//                                              message: error.localizedDescription,
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
    }
    
    private func authorizeRequestToken(_ requestToken: String) {
        let url = URL(string: "https://www.themoviedb.org/authenticate/\(requestToken)?redirect_to=movielister://auth")!
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
        
        AuthenticationCallbackHandler.shared.requestTokenApprovalCallback = { approved in
            self.dismiss(animated: true, completion: {
                if approved {
                    self.startSession(requestToken: requestToken)
                } else {
                    
                    let alert = UIAlertController(title: "Request denied",
                                                  message: "You must approve the login request to log in.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    private func startSession(requestToken: String) {
//        MovieDB.api.send(request: MovieDB.createSession(requestToken: requestToken)) { (result: Result<CreateSessionResponse, APIError>) in
//            switch result {
//            case .success(let response):
//                if response.success {                    
//                    SessionManager.shared.currentSessionId = response.sessionId
//                } else {
//                    self.presentSessionFailureAlert()
//                }
//                
//            case .failure(let error):
//                print("Error: ", error)
//                self.presentSessionFailureAlert()
//            }
//        }
    }

    private func presentSessionFailureAlert() {
        let alert = UIAlertController(title: "Error Starting Session",
                                      message: "Please try logging in again.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
