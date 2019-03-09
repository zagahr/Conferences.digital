//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

final class MainCoordinator {
    var rootViewController: MainViewController
    private var splitViewCoordinator: SplitViewCoordinator
    private var talkService: TalkService

    static var keyEventsActive: Bool = false

    init() {
        rootViewController = MainViewController()
        splitViewCoordinator = SplitViewCoordinator(rootViewController: rootViewController.mainSplitViewController)
        talkService = TalkService()
        talkService.delegate = self
        rootViewController.loadingView.onClicked = talkService.fetchData
    }

    func start() {
        Storage.shared.clearCurrentlyWatching()
        rootViewController.loadingView.show()
        talkService.fetchData()

        if UserDefaults.standard.bool(forKey: "signup") == false {
            UserDefaults.standard.setValue(true, forKey: "signup")
            LoggingHelper.registerSignUp()
        }
    }
}

extension MainCoordinator: TalkServiceDelegate {
    func didFetch(_ talks: [Codable]) {
        MainCoordinator.keyEventsActive = true
        self.rootViewController.loadingView.hide()
        self.splitViewCoordinator.start(with: talks)
    }

    func fetchFailed(with error: APIError) {
        LoggingHelper.register(error: error)
        self.rootViewController.loadingView.show(error)
    }
}
