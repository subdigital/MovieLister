//
//  APIClient.swift
//  MovieLister
//
//  Created by Ben Scheirman on 10/29/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation
import SimpleNetworking

struct MovieDB {
    
    static let baseURL = URL(string: "https://api.themoviedb.org/3/")!
    
    static var api: APIClient = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Authorization" : "Bearer \(apiKey)"
        ]
        return APIClient(configuration: configuration, adapters: [
            SessionAdapter()
        ])
    }()
    
    struct SessionAdapter : RequestAdapter {
        func adapt(_ request: URLRequest) -> URLRequest {
            guard let sessionId = SessionManager.shared.currentSessionId else { return request }
            guard let requestURL = request.url else { return request }
            guard var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else { return request }
            
            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "session_id", value: sessionId))
            components.queryItems = queryItems
            
            var req = request
            req.url = components.url
            return req
        }
    }
    
    struct LoggingAdapter : RequestAdapter {
        func beforeSend(method: HTTPMethod, url: URL) {
            print("Request -> HTTP \(method.rawValue) to \(url)")
        }
    }
    
    struct AuthorizationAdapter : RequestAdapter {
        func adapt(_ request: URLRequest) -> URLRequest {
            guard let requestURL = request.url else { return request }
            guard var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else { return request }
            
            let apiKey = "asdf"
            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "apiKey", value: apiKey))
            components.queryItems = queryItems
            
            var req = request
            req.url = components.url
            return req
        }
    }

}
 
extension Req {
        
    static func popularMovies(completion: @escaping (Result<PagedResults<Movie>, APIError>) -> Void) -> Req {
        Req.basic(baseURL: MovieDB.baseURL, path: "discover/movie", params: [
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]) { result in
            completion(result.decoding(PagedResults<Movie>.self))
        }
    }
    
//    static func configuration() -> Requestable {
//        Request(method: .get, baseURL: MovieDB.baseURL, path: "configuration")
//    }
//
//    static func createRequestToken() -> Requestable {
//        Request(method: .get, baseURL: MovieDB.baseURL, path: "authentication/token/new")
//    }
//
//    static func createSession(requestToken: String) -> Requestable {
//        let body = CreateSessionRequest(request_token: requestToken)
//        return PostRequest(baseURL: MovieDB.baseURL, path: "authentication/session/new", body: body)
//    }
//
//    static func account() -> Requestable {
//        Request(method: .get, baseURL: MovieDB.baseURL, path: "account")
//    }
}
