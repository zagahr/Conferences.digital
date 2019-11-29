//
//  ResourceProtocol.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
}

public protocol Resource {
    var path: String { get }
    var method: HTTPMethod { get }
    var params: [String: String]? { get }
}

public extension Resource {
    func urlRequest() -> URLRequest {

        let url = URL(fileURLWithPath: self.path, relativeTo: URL(string: ConfigManager.baseUrl))

        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = self.method.rawValue

        return urlRequest
    }
}
