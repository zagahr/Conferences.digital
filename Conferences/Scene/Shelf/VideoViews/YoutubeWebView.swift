//
//  YoutubeWebView.swift
//  Conferences
//
//  Created by Timon Blask on 26/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import AVFoundation
import YoutubePlayer_in_WKWebView

protocol Playable: NSViewController {
    var playbackViewModel: PlaybackViewModel? { get set }
    var player: AVPlayer { get set }
    var talk: TalkModel { get set }
    func play()
}

class YoutubeWebViewController: NSViewController, Playable {
    var playbackViewModel: PlaybackViewModel?
    var player: AVPlayer = AVPlayer()
    var talk: TalkModel
    
    private var duration: TimeInterval?
    private var durationFetchRunning = false
    private var timer = 0

    init(talk: TalkModel) {
        self.talk = talk

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var playerView: WKYTPlayerView = {
        let v = WKYTPlayerView(frame: .zero)
        v.delegate = self

        return v
    }()

    override func loadView() {
        view = NSView()
        view.alphaValue = 0

        view.addSubview(playerView)
        playerView.edgesToSuperview()
    }

    func play() {
        duration = nil
        view.alphaValue = 0

        var parameter: [AnyHashable: Any] = ["autoplay": 1, "modestbranding": 1, "showinfo": 0, "fs": 0]

        if let progress = talk.progress {
            parameter["start"] = Int(progress.currentPosition)
        }

        playerView.load(withVideoId: talk.videoId, playerVars: parameter)
    }

    func trackProgress(playTime: Float) {
        guard let duration = duration else { return }

        let p = Double(playTime)
        let d = Double(duration)
        let relative = d.isZero ? 0 :  p / d

        if self.talk.watched == false {
            self.talk.trackProgress(currentPosition: p, relativePosition: relative)

            if relative >= 0.97 {
//                NotificationCenter.default.post(.init(name: .refreshActiveCell, object: true))
            } else {
//                NotificationCenter.default.post(.init(name: .refreshActiveCell))
            }            
        }
    }

    override func removeFromParent() {
        playerView.stopVideo()
        playerView.delegate = nil

        super.removeFromParent()
    }
}

extension YoutubeWebViewController: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        guard view.alphaValue == 0 else { return }

        NSAnimationContext.runAnimationGroup({ _ in
            view.animator().alphaValue = 1
        }, completionHandler: nil)
    }

    func playerView(_ playerView: WKYTPlayerView, didPlayTime playTime: Float) {
        guard durationFetchRunning == false else { return }

        guard timer == 0 else {
            timer -= 1

            return
        }

        timer = 10

        if duration == nil {
            durationFetchRunning = true
            playerView.getDuration { (time, error) in
                if error == nil {
                    self.duration = time
                }

                self.timer = 0
                self.durationFetchRunning = false
            }
        } else {
            trackProgress(playTime: playTime)
        }
    }
}
