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
        return APIClient(
            configuration: configuration,
            adapters: [
                SessionAdapter()
            ],
            logLevel: .debug)
    }()

    static var defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static var defaultEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    struct SessionAdapter : RequestAdapter {
        func adapt(_ request: inout URLRequest) {
            guard let sessionId = SessionManager.shared.currentSessionId else { return }
            guard let requestURL = request.url else { return }
            guard var components = URLComponents(url: requestURL, resolvingAgainstBaseURL: false) else { return }
            
            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "session_id", value: sessionId))
            components.queryItems = queryItems

            request.url = components.url
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
 
extension Request {

    static func popularMovies(_ completion: @escaping (Result<PagedResults<Movie>, APIError>) -> Void) -> Request {
        Request.basic(baseURL: MovieDB.baseURL, path: "discover/movie", params: [
            URLQueryItem(name: "sort_by", value: "popularity.desc")
        ]) { result in
            result.decoding(PagedResults<Movie>.self, completion: completion)
        }
    }
    
    static func configuration(_ completion: @escaping (Result<MovieDBConfiguration, APIError>) -> Void) -> Request {
        Request.basic(baseURL: MovieDB.baseURL, path: "configuration") { result in
            result.decoding(MovieDBConfiguration.self, completion: completion)
        }
    }

    static func createRequestToken(_ completion: @escaping (Result<AuthenticationTokenResponse, APIError>) -> Void) -> Request {
        Request.basic(baseURL: MovieDB.baseURL, path: "authentication/token/new") { result in
            result.decoding(AuthenticationTokenResponse.self, completion: completion)
        }
    }

    static func createSession(requestToken: String, _ completion: @escaping (Result<CreateSessionResponse, APIError>) -> Void) -> Request {
        struct Body : Model {
            let requestToken: String
        }
        return Request.post(baseURL: MovieDB.baseURL, path: "authentication/session/new", body: Body(requestToken: requestToken)) { result in
            result.decoding(CreateSessionResponse.self, completion: completion)
        }
    }

    static func account(_ completion: @escaping (Result<Account, APIError>) -> Void) -> Request {
        Request.basic(baseURL: MovieDB.baseURL, path: "account") { result in
            result.decoding(Account.self, completion: completion)
        }
    }

    static func favoriteMovies(accountID: Int, _ completion: @escaping (Result<PagedResults<Movie>, APIError>) -> Void) -> Request {
        Request.basic(baseURL: MovieDB.baseURL, path: "account/\(accountID)/favorite/movies") { result in
            result.decoding(PagedResults<Movie>.self, completion: completion)
        }
    }

    static func markFavorite(accountID: Int, mediaType: String, mediaID: Int, favorite: Bool, _ completion: @escaping (Result<GenericResponse, APIError>) -> Void) -> Request {
        let body = MarkFavoriteRequest(mediaType: mediaType, mediaId: mediaID, favorite: favorite)
        return Request.post(baseURL: MovieDB.baseURL, path: "account/\(accountID)/favorite", body: body) { result in
            result.decoding(GenericResponse.self, completion: completion)
        }
    }
}
