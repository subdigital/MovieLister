//
//  Model.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 11/20/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public protocol Model : Codable {
    static var decoder: JSONDecoder { get }
    static var encoder: JSONEncoder { get }
}

public extension Model {
    // by default use a basic decoder
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
}

// A type that represents no model value is present
public struct Empty : Model {
}
