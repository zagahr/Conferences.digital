//
//  APIClient+Conferences.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

enum ConferenceResource: Resource {
    case all
    case byOrganisator(Int)

    var path: String {
       return "conferences.json"
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
