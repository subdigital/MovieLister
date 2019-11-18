//
//  SessionManager.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/10/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import Valet

struct SessionManager {
    static var shared = SessionManager()
    
    static let currentUserDidChange: Notification.Name = Notification.Name(rawValue: "currentUserDidChange")
    
    private let keychain: Valet
    private let sessionIdKey = "sessionId"
    
    private init() {
        keychain = Valet.valet(with: Identifier(nonEmpty: "MovieListerKeychain")!, accessibility: .afterFirstUnlock)
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
            NotificationCenter.default.post(name: SessionManager.currentUserDidChange, object: self)
        }
    }
    
    var isLoggedIn: Bool {
        return currentSessionId != nil
    }
    
    mutating func logOut() {
        currentSessionId = nil
    }
}
