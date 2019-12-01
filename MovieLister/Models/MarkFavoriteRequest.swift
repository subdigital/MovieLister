//
//  MarkFavoriteRequest.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/19/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

struct MarkFavoriteRequest : Model {
    let mediaType: String
    let mediaId: Int
    let favorite: Bool
}

extension MarkFavoriteRequest {
    static var encoder: JSONEncoder {
        MovieDB.defaultEncoder
    }
}
