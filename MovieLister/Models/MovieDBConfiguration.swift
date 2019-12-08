//
//  MovieDBConfiguration.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/5/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

struct MovieDBConfiguration : Model {
    
    struct Images : Model {
        let baseUrl: URL
        let secureBaseUrl: URL
        let backdropSizes: [String]
        let logoSizes: [String]
        let posterSizes: [String]
        let profileSizes: [String]
        let stillSizes: [String]
    }
    
    let images: Images
}

extension MovieDBConfiguration {
    
    struct ExpiringConfiguration : Codable {
        let configuration: MovieDBConfiguration
        let expires: Date
        
        var isExpired : Bool {
            return expires < Date()
        }
    }
    
    private static var userDefaultsKey: String { "MovieDBConfiguration" }
    
    static var current: MovieDBConfiguration? {
        get {
            if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
                guard let wrapper = try? PropertyListDecoder().decode(ExpiringConfiguration.self, from: data) else { return nil }
                if wrapper.isExpired {
                    return nil
                }
                return wrapper.configuration
            }
            return nil
        }
        set {
            if let config = newValue {
                let expireInThreeDays = Date().addingTimeInterval(3 * 86400)
                let wrapper = ExpiringConfiguration(configuration: config, expires: expireInThreeDays)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(wrapper), forKey: userDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            }
        }
    }
}

extension MovieDBConfiguration {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
