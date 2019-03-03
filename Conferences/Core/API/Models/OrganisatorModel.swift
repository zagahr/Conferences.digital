//
//  Organisator.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

struct OrganisatorModel: Codable {
    var id: Int
    var name: String
    var twitter: String?
    var nextEvent: String?
}

