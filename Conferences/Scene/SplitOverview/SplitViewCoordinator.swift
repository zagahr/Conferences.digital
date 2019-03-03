//
//  SplitViewCoordinator.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import WebKit
import Crashlytics

final class SplitViewCoordinator {
    let rootViewController: SplitViewController
    var currentPlayer: Playable?
    private var selectedTalk: TalkModel?

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
    func reloadCellAt(index: Int) {
        rootViewController.listViewController.tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet(integer: 0))
    }

    func didSelectTalk(_ talk: TalkModel) {
        self.selectedTalk = talk
        rootViewController.detailViewController.configureView(with: talk)
    }
}

extension SplitViewCoordinator: ShelfViewControllerDelegate {
    func shelfViewControllerDidSelectPlay(_ controller: ShelfViewController) {
        guard var nowPlayingTalk = self.selectedTalk else { return }

        listDataDelegate.removeWatchIcon()
        nowPlayingTalk.currentlyPlaying = true

        currentPlayer?.removeFromParent()

        Answers.logCustomEvent(withName: "Played Talk",
                                       customAttributes: [
                                        "videoId": String(nowPlayingTalk.id),
                                        "source": nowPlayingTalk.source.rawValue
            ])

        switch nowPlayingTalk.source {
            case .vimeo:
                createNativePlayer(controller, talk: nowPlayingTalk)
            case .youtube:
                createWebPlayer(controller, talk: nowPlayingTalk)
        }
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
