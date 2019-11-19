//
//  APIClient.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 10/29/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public protocol RequestAdapter {
    func adapt(_ request: URLRequest) -> URLRequest
    func beforeSend(method: HTTPMethod, url: URL)
    func onError(request: URLRequest)
    func onSuccess(request: URLRequest)
}

public extension RequestAdapter {
    func adapt(_ request: URLRequest) -> URLRequest { return request }
    func beforeSend(method: HTTPMethod, url: URL) { }
    func onError(request: URLRequest) { }
    func onSuccess(request: URLRequest) { }
}

// TODO: Adapter for authentication?
// TODO: Logging adapter?
public struct APIClient {
    
    private let session: URLSession
    private let queue: DispatchQueue
    
    private var adapters: [RequestAdapter]
    
    public init(configuration: URLSessionConfiguration = .default, adapters: [RequestAdapter] = []) {
        self.session = URLSession(configuration: configuration)
        self.adapters = adapters
        queue = DispatchQueue(label: "SimpleNetworking", qos: .userInitiated, attributes: .concurrent)
    }
    
    public func send(request: Req) {
        queue.async {
            var urlRequest = request.builder.toURLRequest()
            for adapter in self.adapters {
                urlRequest = adapter.adapt(urlRequest)
            }
            let task = self.session.dataTask(with: urlRequest) { (data, response, error) in
                let result: Result<Data, APIError>
                if let error = error {
                    result = .failure(.networkError(error))
                } else if let error = APIError.error(from: response) {
                    result = .failure(error)
                } else {
                    result = .success(data ?? Data())
                }
                
                DispatchQueue.main.async {
                    request.completion(result)
                }
            }
            task.resume()
        }
    }
}
