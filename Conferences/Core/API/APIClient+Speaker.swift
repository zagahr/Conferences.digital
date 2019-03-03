//
//  APIClient+Speaker.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import ConferencesCore

extension APIClient {
    public struct Speaker {
        static func all(completionHandler: @escaping (Result<[SpeakerModel], APIError>) -> Void) {
            shared.list(recource: SpeakerResource.all, completionHandler: completionHandler)
        }
    }
}

enum SpeakerResource: Resource {
    case all

    var path: String {
        return "speakers"
    }

    var method: HTTPMethod {
        return HTTPMethod.GET
    }

    var params: [String: String]? {
        return nil
    }
}
