//
//  MovieDetailModel.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/12/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

struct MovieDetailModel {
    let id: Int
    let title: String
    let year: String
    let posterURL: URL?
    
    init(movie: Movie, configuration: MovieDBConfiguration) {
        id = movie.id
        title = movie.title
        year = movie.year

        let imageBase = configuration.images.secureBaseUrl
        
        let largeSizeIndex = configuration.images.posterSizes.count - 2
        guard largeSizeIndex >= 0 else {
            posterURL = nil
            return
        }
        let largeSize = configuration.images.posterSizes[largeSizeIndex]
        
        posterURL = movie.posterPath.flatMap {
            imageBase.appendingPathComponent(largeSize)
                .appendingPathComponent($0)
        }
    }
}
