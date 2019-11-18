//
//  MovieCellModel.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/9/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

struct MovieCellModel : Hashable {
    let id: Int
    let title: String
    let year: String
    let posterURL: URL?
    
    init(movie: Movie, configuration: MovieDBConfiguration) {
        id = movie.id
        title = movie.title
    
        let yearValue = Calendar.current.component(.year, from: movie.releaseDate)
        year = "\(yearValue)"
        
        let imageBase = configuration.images.secureBaseUrl
        
        let middleSizeIndex = configuration.images.posterSizes.count / 2
        guard middleSizeIndex < configuration.images.posterSizes.count else {
            posterURL = nil
            return
        }
        let middleSize = configuration.images.posterSizes[middleSizeIndex]
        
        posterURL = movie.posterPath.flatMap {
            imageBase.appendingPathComponent(middleSize)
                .appendingPathComponent($0)
        }
    }
}
