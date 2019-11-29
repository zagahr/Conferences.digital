//
//  CurrentlyWatchingModel.swift
//  Conferences
//
//  Created by Timon Blask on 27/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import RealmSwift

class CurrentlyWatchingModel: Object {
    @objc dynamic var id = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}
