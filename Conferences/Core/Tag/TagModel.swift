//
//  TagModel.swift
//  Conferences
//
//  Created by Timon Blask on 08/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

struct TagModel: Hashable {
    var title: String
    var query: String
    var isActive: Bool = false

    init(title: String, query: String = "", isActive: Bool = false) {
        self.title = title
        self.query = query.isEmpty ? title.lowercased().replacingOccurrences(of: " ", with: "") : query
        self.isActive = isActive
    }
}

extension TagModel: Equatable {}
