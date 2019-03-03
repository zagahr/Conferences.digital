//
//  APIClient+Conferences.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import ConferencesCore

extension APIClient {
    public struct Conference {
        static func all(completionHandler: @escaping (Result<[ConferenceModel], APIError>) -> Void) {
            shared.list(recource: ConferenceResource.all, completionHandler: completionHandler)
        }
    }
}

enum ConferenceResource: Resource {
    case all
    case byOrganisator(Int)

    var path: String {
       return "conferences"
    }

    var method: HTTPMethod {
        return HTTPMethod.GET
    }

    var params: [String: String]? {
        switch self {
        case .byOrganisator(let id):
            return ["organisatorId": String(id)]
        default:
            return nil
        }
    }
}
