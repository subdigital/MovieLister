//
//  Movie.swift
//  MovieLister
//
//  Created by Ben Scheirman on 10/29/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

struct Movie : Model, Hashable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let releaseDate: Date
    
    private static var releaseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension Movie {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(Movie.releaseDateFormatter)
        return decoder
    }
}
