//
//  TagSyncService.swift
//  Conferences
//
//  Created by Timon Blask on 08/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let clearTags = Notification.Name("ClearTagsNotification")
    static let refreshTagView = Notification.Name("RefreshTagViewNotifiaction")
    static let refreshTableView = Notification.Name("RefreshTableViewNotifiaction")
    static let refreshActiveCell = Notification.Name("RefreshActiveCellNotifiaction")
}

final class TagSyncService {
    public static let shared = TagSyncService()
    private var initalized = false

    private var realmTags: [TagModel] {
        var realmTags: [TagModel] = []

        if !Storage.shared.getWatchlist().isEmpty {
            realmTags.append(.init(title: "Watchlist", query: "realm_watchlist"))
        }

        if !Storage.shared.getModelsForContinue().isEmpty {
            realmTags.append(.init(title: "Continue watching", query: "realm_continue"))
        }

        return realmTags
    }

    private let contentTags: [TagModel] = [
        .init(title: "Swift"),
        .init(title: "Objective-C"),
        .init(title: "2019"),
        .init(title: "2018"),
        .init(title: "iOS"),
        .init(title: "macOS")
    ]

    private var defaultTags: [TagModel] {
        return [realmTags, contentTags].flatMap { $0 }
    }

    var tags: [TagModel] = []

    init() {
        if !initalized {
            self.tags = defaultTags
            initalized = true    
        }
    }

    @objc func clear() {
        if self.tags != defaultTags {
            self.tags = defaultTags

            NotificationCenter.default.post(.init(name: .refreshTagView))
            NotificationCenter.default.post(.init(name: .refreshTableView))
        }
    }

    func handleTag(_ tag: inout TagModel) {
        let existingTage = self.tags

        if tag.isActive && !contains(tags, tag) && !contains(defaultTags, tag) {
            tags.append(tag)
        } else if !tag.isActive && contains(tags, tag) {
            if contains(defaultTags, tag) {
                if let index = tags.firstIndex(where: { $0.query == tag.query }) {
                    tags[index] = tag
                }
            } else {
                tags = tags.filter { $0.query != tag.query}
            }
        } else if tag.isActive && contains(tags, tag) {
            if let index = tags.firstIndex(where: { $0.query == tag.query }) {
                tags[index] = tag
            }
        }

        if existingTage != self.tags {
            NotificationCenter.default.post(.init(name: .refreshTagView))
            NotificationCenter.default.post(.init(name: .refreshTableView))
        }
    }

    func handleStoredTag(_ tag: inout TagModel) {
        let existingTags = self.tags

        if tag.isActive && !contains(tags, tag) {
            loop: for (index, element) in defaultTags.enumerated() {
                if element.query == tag.query {
                    tag.isActive = false
                    tags.insert(tag, at: index)
                    break loop
                }
            }

            NotificationCenter.default.post(.init(name: .refreshTagView))

            return
        } else if !tag.isActive && contains(tags, tag) && !contains(defaultTags, tag) {
            tags = tags.filter { $0.query != tag.query }
        } else if tag.isActive && contains(tags, tag) {
            return
        }

        if existingTags != self.tags {
            NotificationCenter.default.post(.init(name: .refreshTagView))
            NotificationCenter.default.post(.init(name: .refreshTableView))
        }
    }

    private func contains(_ tags: [TagModel], _ tag: TagModel) -> Bool {
        return tags.first(where: {$0.query == tag.query}) != nil
    }
}
