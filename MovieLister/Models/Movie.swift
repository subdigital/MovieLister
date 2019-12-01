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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        
        let releaseDateString = try container.decode(String.self, forKey: .releaseDate)
        releaseDate = Movie.releaseDateFormatter.date(from: releaseDateString)!
    }
}

extension Movie {
    
}
