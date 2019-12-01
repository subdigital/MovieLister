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
public struct APIClient {

    public enum LogLevel : Int {
        case none
        case info
        case debug
    }
    public struct Log {
        var level: LogLevel = .info
        public func message(_ msg: @autoclosure () -> String, level: LogLevel) {
            guard level.rawValue <= self.level.rawValue else { return }
            print(msg())
        }

        public func message(_ utf8Data: @autoclosure () -> Data?, level: LogLevel) {
            guard level.rawValue <= self.level.rawValue else { return }
            let stringValue = utf8Data().flatMap({ String(data: $0, encoding: .utf8 )}) ?? "<empty>"
            message(stringValue, level: level)
        }
    }
    var log = Log()
    
    private let session: URLSession
    private let queue: DispatchQueue
    
    private var adapters: [RequestAdapter]

    public static var defaultEncoder = JSONEncoder()
    public static var defaultDecoder = JSONDecoder()
    
    public init(configuration: URLSessionConfiguration = .default, adapters: [RequestAdapter] = [], logLevel: LogLevel = .info) {
        self.session = URLSession(configuration: configuration)
        self.adapters = adapters
        log.level = logLevel
        queue = DispatchQueue(label: "SimpleNetworking", qos: .userInitiated, attributes: .concurrent)
    }
    
    public func send(request: Request) {
        queue.async {
            var urlRequest = request.builder.toURLRequest()

            self.log.message("Request: \(urlRequest.url?.absoluteString ?? "<?>")", level: .info)
            self.log.message(urlRequest.httpBody, level: .debug)

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

                self.log.message("\(result)", level: .info)
                self.log.message(data, level: .debug)

                DispatchQueue.main.async {
                    request.completion(result)
                }
            }
            task.resume()
        }
    }
}
