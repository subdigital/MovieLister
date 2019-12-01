//
//  Request.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 10/29/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public enum HTTPMethod : String {
    case get
    case post
    case put
    case delete
}

public struct Request {
    let builder: RequestBuilder
    let completion: (Result<Data, APIError>) -> Void
    
    init(builder: RequestBuilder, completion: @escaping (Result<Data, APIError>) -> Void) {
        self.builder = builder
        self.completion = completion
    }
    
    public static func basic(method: HTTPMethod = .get, baseURL: URL, path: String, params: [URLQueryItem]? = nil,
                             completion: @escaping (Result<Data, APIError>) -> Void) -> Request {
        let builder = BasicRequestBuilder(method: method, baseURL: baseURL, path: path, params: params)
        return Request(builder: builder, completion: completion)
    }
    
    public static func post<Body : Model>(method: HTTPMethod = .post, baseURL: URL, path: String, params: [URLQueryItem]? = nil,
                                          body: Body?, completion: @escaping (Result<Data, APIError>) -> Void) -> Request {
        let builder = PostRequestBuilder(method: method, baseURL: baseURL, path: path, params: params, body: body)
        return Request(builder: builder, completion: completion)
    }
}

public extension Result where Success == Data, Failure == APIError {
    func decoding<M : Model>(_ model: M.Type, completion: @escaping (Result<M, APIError>) -> Void) {
        DispatchQueue.global().async {
            let result = self.flatMap { data -> Result<M, APIError> in
                do {
                    let decoder = M.decoder
                    let model = try decoder.decode(M.self, from: data)
                    return .success(model)
                } catch let e as DecodingError {
                    return .failure(.decodingError(e))
                } catch {
                    return .failure(APIError.unhandledResponse)
                }
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
