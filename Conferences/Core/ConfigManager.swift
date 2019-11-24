//
//  Environment.swift
//  Conferences
//
//  Created by Timon Blask on 27/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

public struct Config: Decodable {
    var key: ConfigKey
    var value: String?

    enum ConfigKey: String, Decodable {
        case baseURL
    }
}

public struct ConfigManager {
    public static var baseUrl: String {
        if let url = UserDefaults.standard.string(forKey: Config.ConfigKey.baseURL.rawValue) {
            return url
        } else {
            return "http://127.0.0.1:4000"
        }
    }

    public static func urlRequest(url: URL) -> URLRequest {
        URLRequest(url: url)
    }

    public static func set(_ config: Config) {
        UserDefaults.standard.set(config.value, forKey: config.key.rawValue)
    }
}
