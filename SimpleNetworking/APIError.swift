//
//  APIError.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 11/9/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public enum APIError : Error, CustomStringConvertible {
    case unknownResponse
    case networkError(Error)
    case requestError(Int)
    case serverError(Int)
    case decodingError(DecodingError)
    case unhandledResponse
    
    static func error(from response: URLResponse?) -> APIError? {
        guard let http = response as? HTTPURLResponse else {
            return .unknownResponse
        }
            
        switch http.statusCode {
        case 200...299: return nil
        case 400...499: return .requestError(http.statusCode)
        case 500...599: return .serverError(http.statusCode)
        default: return .unhandledResponse
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .unknownResponse: return "Unknown Response"
        case .networkError(let error): return "Network Error: \(error.localizedDescription)"
        case .requestError(let statusCode): return "HTTP \(statusCode)"
        case .serverError(let statusCode): return "Server error (HTTP \(statusCode))"
        case .decodingError(let decodingError): return "Decoding error: \(decodingError)"
        case .unhandledResponse: return "Unhandled response"
        }
    }
    
    public var description: String {
        localizedDescription
    }
}
