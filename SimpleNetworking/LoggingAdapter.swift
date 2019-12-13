//
//  LoggingAdapter.swift
//  SimpleNetworking
//
//  Created by Ben Scheirman on 12/8/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import Foundation

public struct LoggingAdapter : RequestAdapter {
    public enum LogLevel : Int {
        case none
        case info
        case debug
    }
    struct Log {
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

    private var log = Log()

    public init(logLevel: LogLevel = .info) {
        log.level = logLevel
    }

    public func beforeSend(_ request: URLRequest) {
        guard let url = request.url?.absoluteString else { return }
        let method = request.httpMethod ?? ""
        log.message("📡 \(method) \(url)", level: .info)
        if let body = request.httpBody {
            log.message("Request body:", level: .debug)
            log.message(body, level: .debug)
        }
    }

    public func onResponse(response: URLResponse?, data: Data?) {
        guard let http = response as? HTTPURLResponse else { return }
        log.message("⬇️ Received HTTP \(http.statusCode) from \(http.url?.absoluteString ?? "<?>")", level: .info)
        log.message("Body: ", level: .debug)
        log.message(data, level: .debug)
    }

    public func onError(request: URLRequest) {
        log.message("❌ ERROR:", level: .info)
    }
}
