//
//  WatchlistModel.swift
//  Conferences
//
//  Created by Timon Blask on 08/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import RealmSwift

class WatchlistModel: Object {
    @objc dynamic var id = 0
    @objc dynamic var active = true

    override static func primaryKey() -> String? {
        return "id"
    }
}
