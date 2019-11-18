//
//  URLSchemeHandler.swift
//  MovieLister
//
//  Created by Ben Scheirman on 11/10/19.
//  Copyright © 2019 Fickle Bits. All rights reserved.
//

import UIKit

protocol URLSchemeHandler {
    var host: String { get }
    func handleURL(context: UIOpenURLContext)
}

struct URLSchemeHandlers {
    static var registered: [URLSchemeHandler] {
        return [
            AuthenticationCallbackHandler.shared
        ]
    }
}
