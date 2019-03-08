//
//  Error.swift
//  Conferences
//
//  Created by Timon Blask on 12/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

enum APIError: Error {
    case http(Error)
    case adapter
    case unknown

    var message: String {
        switch self {
        case .http(let error):
            return error.localizedDescription
        case .adapter:
            return "Unable to process the data returned by the server"
        case .unknown:
            return "An unknown networking error occurred"
        }
    }

    var httpError: Error? {
        switch self {
        case .http(let error):
            return error
        default:
            return nil
        }
    }
}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }

    var pushToCrashlytics: Bool {
        if let apiError = self as? APIError, let httpError = apiError.httpError {
            if httpError.code == NSURLErrorNotConnectedToInternet {
                return false
            } else {
                return false
            }
        } else {
            return true
        }
    }
}
