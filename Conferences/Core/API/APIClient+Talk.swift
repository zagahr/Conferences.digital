//
//  APIClient+Talk.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import ConferencesCore

extension APIClient {
    public struct Talk {
        static func all(completionHandler: @escaping (Result<[TalkModel], APIError>) -> Void) {
            shared.list(recource: TalkResource.all, completionHandler: completionHandler)
        }
    }
}

enum TalkResource: Resource {
    case all

    var path: String {
        return "talks"
    }

    var method: HTTPMethod {
        return HTTPMethod.GET
    }

    var params: [String: String]? {
        return nil
    }
}
