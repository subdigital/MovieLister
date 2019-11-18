//
//  AuthenticationTokenResponse.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/10/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

struct AuthenticationTokenResponse : Model {
    let success: Bool
    let expiresAt: Date
    let requestToken: String
}

extension AuthenticationTokenResponse {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        
        // 2019-11-10 19:02:22 UTC
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
