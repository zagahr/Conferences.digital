//
//  SplitViewCoordinator.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import WebKit

final class SplitViewCoordinator {
    private let rootViewController: SplitViewController
    private var currentPlayer: Playable?

    lazy var listDataDelegate: ListViewDataSource = {
        let l = ListViewDataSource()
        l.delegate = self

        return l
    }()

    init(rootViewController: SplitViewController) {
        self.rootViewController = rootViewController
        self.rootViewController.coordinateDelegate = self
    }

    func start(with talks: [Codable]) {
        listDataDelegate.talks = talks
        rootViewController.listViewController.tableView.reloadData()
    }
}

extension SplitViewCoordinator: ListViewDataSourceDelegate {

    func didSelectTalk(_ talk: TalkModel) {
        currentPlayer?.removeFromParent()
        currentPlayer = nil

        rootViewController.detailViewController.configureView(with: talk)
    }

}

extension SplitViewCoordinator: ShelfViewControllerDelegate {
    func shelfViewControllerDidSelectPlay(_ controller: ShelfViewController, talk: TalkModel) {
        currentPlayer?.removeFromParent()
        currentPlayer = nil

        LoggingHelper.register(event: .playTalk, info: ["videoId": String(talk.id), "source": talk.source.rawValue])

        createNativePlayer(controller, talk: talk)
    }

    private func createNativePlayer(_ controller: ShelfViewController, talk: TalkModel) {
        PlaybackViewModel.getVideoUrl(talk: talk) { (url) in
            DispatchQueue.main.async {
                guard let url = url else {
                    ConferencesAlert.show(with: ConferencesError.notFound)
                    return
                }

                let playbackViewModel = PlaybackViewModel(talk: talk, url: url)

                self.currentPlayer = VideoPlayerViewController(player: playbackViewModel.player, session: talk)
                self.currentPlayer?.playbackViewModel = playbackViewModel
                controller.playerController = self.currentPlayer!
            }
        }
    }

    func createWebPlayer(_ controller: ShelfViewController, talk: TalkModel) {
        self.currentPlayer = YoutubeWebViewController(talk: talk)
        controller.playerController = self.currentPlayer!
    }
}
