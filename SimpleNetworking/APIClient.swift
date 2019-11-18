//
//  APIClient.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 10/29/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public protocol RequestAdapter {
    func adapt(_ request: Requestable) -> Requestable
    func beforeSend(method: HTTPMethod, url: URL)
    func onError(request: URLRequest)
    func onSuccess(request: URLRequest)
}

public extension RequestAdapter {
    func adapt(_ request: Requestable) -> Requestable { return request }
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
    
    public func send<M : Model>(request: Requestable, completion: @escaping (Result<M, APIError>) -> Void) {
        queue.async {
            var adaptedRequest = request
            for adapter in self.adapters {
                adaptedRequest = adapter.adapt(adaptedRequest)
            }
            let urlRequest = adaptedRequest.toURLRequest()
            let task = self.session.dataTask(with: urlRequest) { (data, response, error) in
                let result: Result<M, APIError>
                if let error = error {
                    result = .failure(.networkError(error))
                } else if let error = APIError.error(from: response) {
                    result = .failure(error)
                } else {
//                    let body = String(data: data!, encoding: .utf8)
//                    print(body ?? "<?>")                    
                    result = self.decode(data: data)
                }
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            task.resume()
        }
    }
    
    private func decode<M : Model>(data: Data?) -> Result<M, APIError> {
        let data = data ?? Data()
        do {
            let decoder = M.decoder
            let model = try decoder.decode(M.self, from: data)
            return .success(model)
        } catch let e as DecodingError {
            return .failure(.decodingError(e))
        } catch {
            fatalError("Should not happen")
        }
    }
}
