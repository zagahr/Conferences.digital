//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import Crashlytics

final class MainCoordinator {
    var rootViewController: MainViewController
    var splitViewCoordinator: SplitViewCoordinator
    var talkService: TalkService
    static var keyEventsActive: Bool = false

    init() {
        rootViewController = MainViewController()
        splitViewCoordinator = SplitViewCoordinator(rootViewController: rootViewController.mainSplitViewController)
        talkService = TalkService()
        talkService.delegate = self
        rootViewController.loadingView.onClicked = talkService.fetchData
        Storage.shared.clearCurrentlyWatching()
    }

    func start() {
        rootViewController.loadingView.show()
        talkService.fetchData()
    }
}

extension MainCoordinator: TalkServiceDelegate {
    func didFetch(_ talks: [Codable]) {

        if UserDefaults.standard.bool(forKey: "signup") == false {
            UserDefaults.standard.setValue(true, forKey: "signup")
            Answers.logSignUp(withMethod: nil, success: nil, customAttributes: nil)
        }

        MainCoordinator.keyEventsActive = true

        self.rootViewController.loadingView.hide()
        self.splitViewCoordinator.start(with: talks)
    }

    func fetchFailed(with error: APIError) {
        Answers.logCustomEvent(withName: "Initial fetch failed", customAttributes: nil)
        self.rootViewController.loadingView.show(error)
    }
}
