//
//  AuthenticationCallbackHandler.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/10/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit

class AuthenticationCallbackHandler : URLSchemeHandler {
    var host = "auth"
    
    static let shared = AuthenticationCallbackHandler()
    
    private init() { }
    
    var requestTokenApprovalCallback: ((Bool) -> Void)?
    
    func handleURL(context: UIOpenURLContext) {
        guard let components = URLComponents(url: context.url, resolvingAgainstBaseURL: false) else { return }
        guard let requestToken = components.queryItems?.first(where: { $0.name == "request_token" })?.value else { return }
        let approved = (components.queryItems?.first(where: { $0.name == "approved" })?.value == "true")
        
        print("Request token \(requestToken) \(approved ? "was" : "was NOT") approved")
        
        requestTokenApprovalCallback?(approved)
    }
}
