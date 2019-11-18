//
//  PagedResults.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/5/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

struct PagedResults<Item : Model> : Model {
    let page: Int
    let totalPages: Int
    let results: [Item]
}

extension PagedResults {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
