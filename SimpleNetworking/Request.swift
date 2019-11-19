//
//  Request.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 10/29/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public enum HTTPMethod : String {
    case get = "GET"
    case post = "POST"
}

public protocol URLRequestConvertible {
    func toURLRequest() -> URLRequest
}

extension URLRequest : URLRequestConvertible {
    public func toURLRequest() -> URLRequest {
        return self
    }
}

extension URL : URLRequestConvertible {
    public func toURLRequest() -> URLRequest {
        return URLRequest(url: self)
    }
}

public protocol Model : Codable {
    static var decoder: JSONDecoder { get }
}

public extension Model {
    
    // by default use a basic decoder
    static var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    static var encoder: JSONEncoder {
        return JSONEncoder()
    }
}

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

public struct Req {
    let builder: RequestBuilder
    let completion: (Result<Data, APIError>) -> Void
    
    init(builder: RequestBuilder, completion: @escaping (Result<Data, APIError>) -> Void) {
        self.builder = builder
        self.completion = completion
    }
    
    public static func basic(method: HTTPMethod = .get, baseURL: URL, path: String, params: [URLQueryItem]? = nil, completion: @escaping (Result<Data, APIError>) -> Void) -> Req {
        let builder = BasicRequestBuilder(method: method, baseURL: baseURL, path: path, params: params)
        return Req(builder: builder, completion: completion)
    }
    
    public static func post<Body : Model>(method: HTTPMethod = .post, baseURL: URL, path: String, params: [URLQueryItem]? = nil, body: Body?, completion: @escaping (Result<Data, APIError>) -> Void) -> Req {
        let builder = PostRequestBuilder(method: method, baseURL: baseURL, path: path, params: params, body: body)
        return Req(builder: builder, completion: completion)
    }
}

public extension Result where Success == Data, Failure == APIError {
    func decoding<M : Model>(_ model: M.Type) -> Result<M, APIError> {
        return flatMap { data -> Result<M, APIError> in
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

// A type that represents no model value is present
public struct Empty : Model {
}
