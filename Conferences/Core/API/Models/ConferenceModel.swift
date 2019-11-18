//
//  Conferences.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

struct ConferenceModel: Codable {
    var id: String
    var organisator: OrganisatorModel
    var name: String
    var url: String
    var location: String
    var date: String?
    var highlightColor: String
    var talks: [TalkModel]
    var about: String
}

extension ConferenceModel: Searchable {
    var searchString: String {
        return "\(String(describing: date)) \(location)  \(name)\(organisator.name)".lowercased()
    }
}

extension ConferenceModel {
    var logo: String {
        return "\(ConfigManager.baseUrl)images/conferences/\(id).png"
    }
}
