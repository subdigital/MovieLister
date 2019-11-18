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
        func adapt(_ request: Requestable) -> Requestable {
            guard let sessionId = SessionManager.shared.currentSessionId else { return request }
            var req = request
            var params = req.params ?? []
            params.append(URLQueryItem(name: "session_id", value: sessionId))
            req.params = params
            return req
        }
    }
    
    struct LoggingAdapter : RequestAdapter {
        func beforeSend(method: HTTPMethod, url: URL) {
            print("Request -> HTTP \(method.rawValue) to \(url)")
        }
    }
    
    struct AuthorizationAdapter : RequestAdapter {
        func adapt(_ request: Requestable) -> Requestable {
            var req = request
            var params = req.params ?? []
            let apiKey = "asdfasdf"
            params.append(URLQueryItem(name: "apiKey", value: apiKey))
            req.params = params
            return req
        }
    }

}
 
extension Requestable {
    static func popularMovies() -> Requestable {
        Request(method: .get, baseURL: MovieDB.baseURL, path: "discover/movie", params: [
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ])
    }
    
    static func configuration() -> Requestable {
        Request(method: .get, baseURL: MovieDB.baseURL, path: "configuration")
    }
    
    static func createRequestToken() -> Requestable {
        Request(method: .get, baseURL: MovieDB.baseURL, path: "authentication/token/new")
    }
    
    static func createSession(requestToken: String) -> Requestable {
        let body = CreateSessionRequest(request_token: requestToken)
        return PostRequest(baseURL: MovieDB.baseURL, path: "authentication/session/new", body: body)
    }
    
    static func account() -> Requestable {
        Request(method: .get, baseURL: MovieDB.baseURL, path: "account")
    }
}
