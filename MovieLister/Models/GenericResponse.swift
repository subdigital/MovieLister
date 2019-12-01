//
//  GenericResponse.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/19/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

struct GenericResponse : Model {
    let statusCode: Int
    let statusMessage: String
}

extension GenericResponse {
    static var decoder: JSONDecoder {
        MovieDB.defaultDecoder
    }
}
