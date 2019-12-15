//
//  SessionManager.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/10/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import Valet
import UIKit
import SafariServices

class SessionManager {
    static let currentUserDidChange: Notification.Name = Notification.Name(rawValue: "currentUserDidChange")
    
    private let keychain: Valet
    private let sessionIdKey = "sessionId"
    private let accountIdKey = "accountId"
    
    init() {
        keychain = Valet.valet(with: Identifier(nonEmpty: "MovieListerKeychain")!, accessibility: .afterFirstUnlock)
    }

    var currentAccountId: Int? {
        get {
            keychain.string(forKey: accountIdKey).flatMap(Int.init)
        }
        set {
            if let value = newValue {
                keychain.set(string: String(value), forKey: accountIdKey)
            } else {
                keychain.removeObject(forKey: accountIdKey)
            }
        }
    }
    
    var currentSessionId: String? {
        get {
            keychain.string(forKey: sessionIdKey)
        }
        set {
            if let value = newValue {
                keychain.set(string: value, forKey: sessionIdKey)
            } else {
                keychain.removeObject(forKey: sessionIdKey)
            }
        }
    }
    
    var isLoggedIn: Bool {
        return currentSessionId != nil
    }

    func startLogin(from viewController: UIViewController) {
        MovieDB.api.send(request: .createRequestToken({ result in
            switch result {
            case .success(let response):
                self.authorizeRequestToken(from: viewController, requestToken: response.requestToken)

            case .failure(let error):                
                viewController.present(self.requestTokenFailureAlert(error: error), animated: true, completion: nil)
            }
        }))
    }

    private func authorizeRequestToken(from viewController: UIViewController, requestToken: String) {
        let url = URL(string: "https://www.themoviedb.org/authenticate/\(requestToken)?redirect_to=movielister://auth")!
        let safariVC = SFSafariViewController(url: url)
        viewController.present(safariVC, animated: true, completion: nil)

        AuthenticationCallbackHandler.shared.requestTokenApprovalCallback = { approved in
            viewController.dismiss(animated: true, completion: {
                if approved {
                    self.startSession(requestToken: requestToken) { success in
                        if !success {
                            viewController.present(self.sessionFailureAlert(), animated: true, completion: nil)
                        }
                    }
                } else {
                    viewController.present(self.requestDeniedAlert(), animated: true, completion: nil)
                }
            })
        }
    }

    private func startSession(requestToken: String, completion: @escaping (Bool) -> Void) {
        MovieDB.api.send(request: .createSession(requestToken: requestToken) { result in
            switch result {
            case .success(let response):
                if response.success {
                    self.currentSessionId = response.sessionId
                    Current.accountManager.fetchAccount { result in
                        switch result {
                        case .success(let account):
                            self.currentAccountId = account.id
                            NotificationCenter.default.post(name: SessionManager.currentUserDidChange, object: self)
                        case .failure(let error):
                            print("Error fetching account", error)
                        }
                    }
                }
                completion(response.success)

            case .failure(let error):
                print("Error: ", error)
                completion(false)
            }
        })
    }

    private func requestTokenFailureAlert(error: Error) -> UIAlertController {
        let alert = UIAlertController(title: "Error fetching request token",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }

    private func sessionFailureAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Error Starting Session",
                                      message: "Please try logging in again.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }

    private func requestDeniedAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Request denied",
                                      message: "You must approve the login request to log in.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }

    
    func logOut() {
        currentSessionId = nil
        NotificationCenter.default.post(name: SessionManager.currentUserDidChange, object: self)
    }
}
