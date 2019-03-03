//
//  PlaybackViewModel.swift
//  Conferences
//
//  Created by Timon Blask on 22/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import AVFoundation

enum ConferencesError: Error {
    case notFound
    case other(String)

    var message: String {
        switch self {
        case .notFound:
            return "Unable to play video"
        case .other(let message):
            return message
        }
    }
}

final class PlaybackViewModel {

    var talk: TalkModel
    let player: AVPlayer
    private var timeObserver: Any?

    init(talk: TalkModel, url: URL) {
        self.talk = talk

        player = AVPlayer(url: url)

        if let progress = talk.progress, !progress.watched {
            player.seek(to: CMTimeMakeWithSeconds(Float64(progress.currentPosition), preferredTimescale: 9000))
        } else {
            player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 9000))
        }

        if talk.watched == false {
            timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(5, preferredTimescale: 9000), queue: DispatchQueue.main) { [weak self] currentTime in
                guard let self = self else { return }

                guard let duration = self.player.currentItem?.asset.durationIfLoaded else { return }

                guard CMTIME_IS_VALID(duration) else { return }

                let p = Double(CMTimeGetSeconds(currentTime))
                let d = Double(CMTimeGetSeconds(duration))
                let relative = d.isZero ? 0 :  p / d

                if self.talk.watched == false {
                    self.talk.trackProgress(currentPosition: p, relativePosition: relative)

                    if relative >= 0.97 {
                        NotificationCenter.default.post(.init(name: .refreshActiveCell, object: true))
                    } else {
                        NotificationCenter.default.post(.init(name: .refreshActiveCell))
                    }

                    //Refresh top
                    var tag = TagModel(title: "Continue watching", query: "realm_continue", isActive: true)
                    TagSyncService.shared.handleStoredTag(&tag)
                }
            }
        }
    }

    static func getVideoUrl(talk: TalkModel, completionHandler: @escaping ((URL?) -> Void)) {
        switch talk.source {
        case .youtube:
            Youtube.loadVideoInfos(youtubeID: talk.videoId, completionHandler: completionHandler)
        case .vimeo:
            HCVimeoVideoExtractor.fetchVideoURLFrom(id: talk.videoId, completionHandler: completionHandler)
        }
    }

    deinit {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }
}

