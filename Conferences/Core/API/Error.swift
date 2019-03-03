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
}
