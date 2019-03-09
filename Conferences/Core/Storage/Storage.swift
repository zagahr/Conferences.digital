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
        let filePath = PathUtil.appSupportPathAssumingExisting + "/default.realm"

        var realmConfig = Realm.Configuration(fileURL: URL(fileURLWithPath: filePath))
        realmConfig.objectTypes = [ProgressModel.self, WatchlistModel.self, CurrentlyWatchingModel.self ]

        return try? Realm(configuration: realmConfig)
    }

    private lazy var realm: Realm? = {
        return self.makeRealm()
    }()

    func getProgress(for id: Int) ->  ProgressModel? {
        return realm?.object(ofType: ProgressModel.self, forPrimaryKey: id)
    }

    func isOnWatchlist(for id: Int) -> WatchlistModel? {
        return realm?.object(ofType: WatchlistModel.self, forPrimaryKey: id)
    }

    func getModelsForContinue() -> [Int] {
        return realm?.objects(ProgressModel.self).filter { $0.watched == false && $0.relativePosition > 0 }.map { $0.id } ?? []
    }

    func getWatchlist() -> [Int] {
        return realm?.objects(WatchlistModel.self).filter { $0.active == true }.map { $0.id } ?? []
    }

    func setFavorite(_ object: WatchlistModel)   {
        try! realm?.write {
            if object.active {
                LoggingHelper.register(event: .addToWatchlist, info: ["videoId": String(object.id)])
                realm?.add(object, update: true)
            } else {
                if let objectToRemove = realm?.object(ofType: WatchlistModel.self, forPrimaryKey: object.id) {
                    LoggingHelper.register(event: .removeFromWatchlist, info: ["videoId": String(object.id)])
                    realm?.delete(objectToRemove)
                }
            }
        }
    }

    func trackProgress(object: ProgressModel)   {
        try! realm?.write {
            realm?.add(object, update: true)
        }
    }

    func currentlyWatching(object: CurrentlyWatchingModel)   {
        try! realm?.write {
            if let objectToRemove = realm?.object(ofType: CurrentlyWatchingModel.self, forPrimaryKey: object.id) {
                realm?.delete(objectToRemove)
            } else {
                realm?.add(object, update: true)
            }
        }
    }

    func currentlyWatching(for id: Int) -> Bool {
        if let _ = realm?.object(ofType: CurrentlyWatchingModel.self, forPrimaryKey: id) {
            return true
        } else {
            return false
        }
    }

    func clearCurrentlyWatching() {
        guard let currentlyWatching = realm?.objects(CurrentlyWatchingModel.self) else { return }

        try! realm?.write {
            realm?.delete(currentlyWatching)
        }
    }
}
