//
//  AccountContainerViewController.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/10/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit

class AccountContainerViewController : UIViewController {
    
    private enum Mode {
        case loggedOut(LoginViewController)
        case loggedIn(AccountViewController)
        
        var viewController: UIViewController {
            switch self {
            case .loggedOut(let vc): return vc
            case .loggedIn(let vc): return vc
            }
        }
    }
    
    private var child: UIViewController? {
        willSet {
            if let oldChild = child {
                oldChild.willMove(toParent: nil)
                oldChild.removeFromParent()
                oldChild.view.removeFromSuperview()
            }
        }
        didSet {
            if let newChild = child {
                view.addSubview(newChild.view)
                NSLayoutConstraint.activate([
                    view.leadingAnchor.constraint(equalTo: newChild.view.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: newChild.view.trailingAnchor),
                    view.topAnchor.constraint(equalTo: newChild.view.topAnchor),
                    view.bottomAnchor.constraint(equalTo: newChild.view.bottomAnchor),
                ])
                addChild(newChild)
                newChild.didMove(toParent: self)
            }
        }
    }
    
    private var mode: Mode! {
        didSet {
            child = mode.viewController
            title = child?.title
        }
    }
    
    private var notificationToken: NSObjectProtocol?
    
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Current.sessionManager.isLoggedIn {
            title = "Account"
        } else {
            title = "Login"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        updateChildController()
        
        notificationToken = NotificationCenter.default.addObserver(forName: SessionManager.currentUserDidChange, object: nil, queue: nil, using: { _ in
            self.updateChildController()
        })
    }
    
    private func updateChildController() {
        guard let storyboard = storyboard else { return }
        
        if Current.sessionManager.isLoggedIn {
            let accountVC = storyboard.instantiateViewController(identifier: "AccountViewController") as! AccountViewController
            mode = .loggedIn(accountVC)
        } else {
            let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            mode = .loggedOut(loginVC)
        }
    }
}
