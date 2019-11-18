//
//  Speaker.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

struct SpeakerModel: Codable {
    var id: String
    var firstname: String
    var lastname: String
    var image: String?
    var twitter: String?
    var github: String?
    var about: String?
}
