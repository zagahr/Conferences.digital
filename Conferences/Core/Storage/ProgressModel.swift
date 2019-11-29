//
//  ProgressModel.swift
//  Conferences
//
//  Created by Timon Blask on 08/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import RealmSwift

class ProgressModel: Object {
    @objc dynamic var id = ""
    @objc dynamic var watched = false
    @objc dynamic var currentPosition = 0.0
    @objc dynamic var relativePosition = 0.0

    override static func primaryKey() -> String? {
        return "id"
    }
}
