//
//  World.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/19/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

struct World {
    static var current = World()
    static var sessionManager = SessionManager.shared
    static var accountManager = AccountManager()
}
