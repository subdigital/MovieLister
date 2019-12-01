//
//  RequestBuilder.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 11/20/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public protocol RequestBuilder : URLRequestConvertible {
    var method: HTTPMethod { get set }
    var baseURL: URL { get set }
    var path: String { get set }
    var params: [URLQueryItem]? { get set }
    var headers: [String : String] { get set }

    func encodeRequestBody() -> Data?
}

extension RequestBuilder {
    public func encodeRequestBody() -> Data? {
        return nil
    }

    public func toURLRequest() -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = params
        let url = components.url!

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        request.httpBody = encodeRequestBody()
        return request
    }
}

struct BasicRequestBuilder : RequestBuilder {
    public var method: HTTPMethod
    public var baseURL: URL
    public var path: String
    public var params: [URLQueryItem]?
    public var headers: [String : String] = [:]

    public init(method: HTTPMethod, baseURL: URL, path: String, params: [URLQueryItem]? = nil) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.params = params
    }
}

struct PostRequestBuilder<Body : Model> : RequestBuilder {
    public var method: HTTPMethod
    public var baseURL: URL
    public var path: String
    public var params: [URLQueryItem]?
    public var headers: [String : String] = [:]
    public var body: Body?

    public init(method: HTTPMethod = .post, baseURL: URL, path: String, params: [URLQueryItem]? = nil, body: Body?) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.params = params
        self.body = body
        self.headers["Content-Type"] = "application/json"
    }

    public func encodeRequestBody() -> Data? {
        guard let body = body else { return nil }
        do {
            let encoder = Body.encoder
            return try encoder.encode(body)
        } catch {
            print("Error encoding request body: \(error)")
            return nil
        }
    }
}
