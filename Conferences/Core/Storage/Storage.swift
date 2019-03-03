//
//  Storage.swift
//  Conferences
//
//  Created by Timon Blask on 03/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//


import RealmSwift
import Crashlytics

final class Storage {
    private var database: Realm
    static let shared = Storage()

    private init() {
        database = try! Realm()
    }

    func getProgress(for id: Int) ->  ProgressModel? {
        return database.object(ofType: ProgressModel.self, forPrimaryKey: id)
    }

    func isOnWatchlist(for id: Int) -> WatchlistModel? {
        return database.object(ofType: WatchlistModel.self, forPrimaryKey: id)
    }

    func getModelsForContinue() -> [Int] {
        return database.objects(ProgressModel.self).filter { $0.watched == false && $0.relativePosition > 0 }.map { $0.id }
    }

    func getWatchlist() -> [Int] {
        return database.objects(WatchlistModel.self).filter { $0.active == true }.map { $0.id }
    }

    func setFavorite(_ object: WatchlistModel)   {
        try! database.write {
            if object.active {
                Answers.logCustomEvent(withName: "Added to Watchlist",
                                       customAttributes: [
                                        "videoId": String(object.id)])
                database.add(object, update: true)
            } else {
                if let objectToRemove = database.object(ofType: WatchlistModel.self, forPrimaryKey: object.id) {
                    Answers.logCustomEvent(withName: "Removed from Watchlist",
                                           customAttributes: [
                                            "videoId": String(object.id)])
                    database.delete(objectToRemove)
                }
            }
        }
    }

    func trackProgress(object: ProgressModel)   {
        try! database.write {
            database.add(object, update: true)
        }
    }

    func currentlyWatching(object: CurrentlyWatchingModel)   {
        try! database.write {
            if let objectToRemove = database.object(ofType: CurrentlyWatchingModel.self, forPrimaryKey: object.id) {
                database.delete(objectToRemove)
            } else {
                database.add(object, update: true)
            }
        }
    }

    func currentlyWatching(for id: Int) -> Bool {
        if let _ = database.object(ofType: CurrentlyWatchingModel.self, forPrimaryKey: id) {
            return true
        } else {
            return false
        }
    }

    func clearCurrentlyWatching() {
        let realm = try! Realm()
        let allUploadingObjects = realm.objects(CurrentlyWatchingModel.self)

        try! realm.write {
            realm.delete(allUploadingObjects)
        }
    }
}
