//
//  CreationSessionRequest.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/17/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

struct CreateSessionRequest : Model {
    let request_token: String
}
