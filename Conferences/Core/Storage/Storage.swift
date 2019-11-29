//
//  Storage.swift
//  Conferences
//
//  Created by Timon Blask on 03/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import RealmSwift

final class Storage {
    static let shared = Storage()

    private func makeRealm() -> Realm? {
        let filePath = PathUtil.appSupportPathAssumingExisting + "/default_v2.realm"

        var realmConfig = Realm.Configuration(fileURL: URL(fileURLWithPath: filePath))
        realmConfig.objectTypes = [ProgressModel.self, WatchlistModel.self]

        return try? Realm(configuration: realmConfig)
    }

    private lazy var realm: Realm? = {
        self.makeRealm()
    }()

    func getProgress(for id: String) -> ProgressModel? {
        return realm?.object(ofType: ProgressModel.self, forPrimaryKey: id)
    }

    func trackProgress(object: ProgressModel) {
        try! realm?.write {
            realm?.add(object, update: .all)
        }
    }

    func isOnWatchlist(for id: String) -> WatchlistModel? {
        return realm?.object(ofType: WatchlistModel.self, forPrimaryKey: id)
    }


    func getWatchlist() -> [String] {
        return realm?.objects(WatchlistModel.self).filter { $0.active == true }.map { $0.id } ?? []
    }

    func addToWatchlist(_ object: WatchlistModel) {
        try! realm?.write {
            if object.active {
                LoggingHelper.register(event: .addToWatchlist, info: ["videoId": String(object.id)])
                realm?.add(object, update: .all)
            } else {
                if let objectToRemove = realm?.object(ofType: WatchlistModel.self, forPrimaryKey: object.id) {
                    LoggingHelper.register(event: .removeFromWatchlist, info: ["videoId": String(object.id)])
                    realm?.delete(objectToRemove)
                }
            }
        }
    }

}
