//
//  APIClient.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 10/29/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public protocol RequestAdapter {
    func adapt(_ request: inout URLRequest)
    func beforeSend(_ request: URLRequest)
    func onResponse(response: URLResponse?, data: Data?)
    func onError(request: URLRequest, error: APIError)
    func onSuccess(request: URLRequest)
}

public extension RequestAdapter {
    func adapt(_ request: inout URLRequest) { }
    func beforeSend(_ request: URLRequest) { }
    func onResponse(response: URLResponse?, data: Data?) { }
    func onError(request: URLRequest, error: APIError) { }
    func onSuccess(request: URLRequest) { }
}

public struct APIClient {

    
    private let session: URLSession
    private let queue: DispatchQueue
    
    private var adapters: [RequestAdapter]

    public static var defaultEncoder = JSONEncoder()
    public static var defaultDecoder = JSONDecoder()
    
    public init(configuration: URLSessionConfiguration = .default, adapters: [RequestAdapter] = []) {
        self.session = URLSession(configuration: configuration)
        self.adapters = adapters
        queue = DispatchQueue(label: "SimpleNetworking", qos: .userInitiated, attributes: .concurrent)
    }
    
    public func send(request: Request) {
        queue.async {
            var urlRequest = request.builder.toURLRequest()

            self.adapters.forEach { $0.adapt(&urlRequest) }
            self.adapters.forEach { $0.beforeSend(urlRequest) }

            let task = self.session.dataTask(with: urlRequest) { (data, response, error) in
                self.adapters.forEach { $0.onResponse(response: response, data: data) }

                let result: Result<Data, APIError>
                if let error = error {
                    result = .failure(.networkError(error))
                } else if let apiError = APIError.error(from: response) {
                    result = .failure(apiError)
                } else {
                    result = .success(data ?? Data())
                }

                // notify adapters
                switch result {
                case .success:
                    self.adapters.forEach { $0.onSuccess(request: urlRequest) }
                case .failure(let error):
                    self.adapters.forEach { $0.onError(request: urlRequest, error: error) }
                }

                DispatchQueue.main.async {
                    request.completion(result)
                }
            }
            task.resume()
        }
    }
}
