//
//  LoggingHelper.swift
//  Conferences
//
//  Created by Timon Blask on 07/03/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa
import Crashlytics
import Fabric

enum AnswerEvent: String {
    // "Opend" ¯\_(ツ)_/¯
    case openSpeakerTwitter = "Opend Speakers Twitter"
    case openSpeakerGithub = "Opend Speakers GitHub"
    case openConferenceHomepage = "Opend Conference Homepage"
    case openConferenceTwitter = "Opend Conference Twitter"
    case openDonate = "Opend Donate"
    case openStarOnGitHub = "Opend Star on GitHub"
    case addToWatchlist = "Added to Watchlist"
    case removeFromWatchlist = "Removed from Watchlist"
    case playTalk = "Played Talk"
    case searchFor = "Searched for"
    case rightClickonTable = "Right click table"
}

final class LoggingHelper {

    static func install() {
        Fabric.with([Crashlytics.self])
    }

    static func register(error: Error, info: [String: Any]? = nil) {
        if error.pushToCrashlytics {
            if let apiError = error as? APIError {
                if let httpError = apiError.httpError {
                    Crashlytics.sharedInstance().recordError(httpError, withAdditionalUserInfo: ["message": error.localizedDescription])
                } else {
                    Crashlytics.sharedInstance().recordError(apiError, withAdditionalUserInfo: ["message": error.localizedDescription])
                }
            } else {
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["message": error.localizedDescription])
            }
        }
    }

    static func register(event: AnswerEvent, info: [String: Any] = [:]) {
        Answers.logCustomEvent(withName: event.rawValue, customAttributes: info)
    }

    static func registerSignUp(with name: String? = nil, success: NSNumber? = nil, info: [String: Any]? = nil) {
        Answers.logSignUp(withMethod: name, success: success, customAttributes: info)
    }
}
