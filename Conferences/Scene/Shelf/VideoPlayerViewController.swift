//
//  VideoPlayerViewController.swift
//  Conferences
//
//  Created by Timon Blask on 04/06/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Cocoa
import AVFoundation

extension Notification.Name {
    static let HighlightTranscriptAtCurrentTimecode = Notification.Name("HighlightTranscriptAtCurrentTimecode")
}


final class VideoPlayerViewController: NSViewController, Playable {
    var playbackViewModel: PlaybackViewModel?

    var talk: TalkModel
    var player: AVPlayer

    var playerWillExitPictureInPicture: ((PUIPiPExitReason) -> Void)?
    var playerWillExitFullScreen: (() -> Void)?

    init(player: AVPlayer, session: TalkModel) {
        talk = session
        self.player = player

        super.init(nibName: nil, bundle: nil)
    }

    func play() {
        playerView.delegate = self
        resetAppearanceDelegate()
        reset(oldValue: nil)
    }

    required public init?(coder: NSCoder) {
        fatalError("VideoPlayerViewController can't be initialized with a coder")
    }

    lazy var playerView: PUIPlayerView = {
        return PUIPlayerView(player: self.player)
    }()

    fileprivate lazy var progressIndicator: NSProgressIndicator = {
        let p = NSProgressIndicator(frame: NSRect.zero)

        p.controlSize = .regular
        p.style = .spinning
        p.isIndeterminate = true
        p.translatesAutoresizingMaskIntoConstraints = false
        p.appearance = NSAppearance(named: NSAppearance.Name(rawValue: "WhiteSpinner"))
        p.isHidden = true

        p.sizeToFit()

        return p
    }()

    override func loadView() {
        view = NSView(frame: NSRect.zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor

        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.frame = view.bounds
        view.addSubview(playerView)

        //todo chromecast
       //playerView.registerExternalPlaybackProvider(ChromeCastPlaybackProvider.self)

        playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        view.addSubview(progressIndicator)
        view.addConstraints([
            NSLayoutConstraint(item: progressIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: progressIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            ])

        progressIndicator.layer?.zPosition = 999
    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        playerView.delegate = self
//        resetAppearanceDelegate()
//        reset(oldValue: nil)
//    }

    func resetAppearanceDelegate() {
        playerView.appearanceDelegate = self
    }

    func reset(oldValue: AVPlayer?) {
        if let oldPlayer = oldValue {
            if let boundaryObserver = boundaryObserver {
                oldPlayer.removeTimeObserver(boundaryObserver)
                self.boundaryObserver = nil
            }

            playerView.player = nil

            oldPlayer.pause()
            oldPlayer.cancelPendingPrerolls()
            oldPlayer.currentItem?.cancelPendingSeeks()
            oldPlayer.currentItem?.asset.cancelLoading()
        }

        setupPlayerObservers()

        playerView.player = player
        playerView.play(self)
        playerView.mediaIsLiveStream = false
    }

    // MARK: - Player Observation

    private var playerStatusObserver: NSKeyValueObservation?
    private var currentItemStatusObserver: NSKeyValueObservation?
    private var presentationSizeObserver: NSKeyValueObservation?
    private var currentItemObserver: NSKeyValueObservation?
    private var timeControlStatusObserver: NSKeyValueObservation?

    private func setupPlayerObservers() {

        playerStatusObserver = player.observe(\.status, options: [.initial, .new], changeHandler: { [weak self] (player, change) in
            guard let self = self else { return }
            DispatchQueue.main.async(execute: self.showPlaybackErrorIfNeeded)
        })

        timeControlStatusObserver = player.observe(\AVPlayer.timeControlStatus) { [weak self] (player, change) in
            guard let self = self else { return }
            DispatchQueue.main.async(execute: self.timeControlStatusDidChange)
        }

        currentItemObserver = player.observe(\.currentItem, options: [.initial, .new]) { [weak self] (player, change) in
            self?.presentationSizeObserver = player.currentItem?.observe(\.presentationSize, options: [.initial, .new]) { [weak self] (player, change) in
                guard let self = self else { return }
                DispatchQueue.main.async(execute: self.playerItemPresentationSizeDidChange)
            }

            self?.currentItemStatusObserver = player.currentItem?.observe(\.status) { item, _ in
                guard let self = self else { return }
                self.showPlaybackErrorIfNeeded()
            }
        }
    }

    private func playerItemPresentationSizeDidChange() {
        guard let size = player.currentItem?.presentationSize, size != NSSize.zero else { return }

        (view.window as? PUIPlayerWindow)?.aspectRatio = size
    }

    private func showPlaybackErrorIfNeeded() {
        if let _ = player.error ?? player.currentItem?.error {
            ConferencesAlert.show(with: ConferencesError.notFound)
        }
    }

    private func timeControlStatusDidChange() {
        func showLoading() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                guard self?.player.timeControlStatus == .waitingToPlayAtSpecifiedRate else { return }
                self?.progressIndicator.startAnimation(nil)
                self?.progressIndicator.isHidden = false
            }
        }

        func hideLoading() {
            if !progressIndicator.isHidden {
                progressIndicator.stopAnimation(nil)
                progressIndicator.isHidden = true
            }
        }

        switch player.timeControlStatus {
        case .waitingToPlayAtSpecifiedRate:
            showLoading()
        case .playing, .paused:
            hideLoading()
        }
    }

    private var boundaryObserver: Any?
    // MARK: - Detach

    var detachedWindowController: VideoPlayerWindowController!

    func detach(forEnteringFullscreen fullscreen: Bool = false) {
        view.translatesAutoresizingMaskIntoConstraints = true

        detachedWindowController = VideoPlayerWindowController(playerViewController: self, fullscreenOnly: fullscreen, originalContainer: view.superview)
        detachedWindowController.contentViewController = self

        detachedWindowController.actionOnWindowClosed = { [weak self] in
            self?.detachedWindowController = nil
        }

        detachedWindowController.actionOnWindowWillExitFullScreen = { [weak self] in
            self?.playerWillExitFullScreen?()
        }

        detachedWindowController.showWindow(self)
    }

    override func removeFromParent() {
        playerView.delegate = nil
        playerView.player = nil
        playerView.appearanceDelegate = nil
        playbackViewModel = nil

        super.removeFromParent()
    }

    deinit {
        playerStatusObserver?.invalidate()
        currentItemStatusObserver?.invalidate()
        presentationSizeObserver?.invalidate()
        currentItemObserver?.invalidate()
        timeControlStatusObserver?.invalidate()
    }
}

extension VideoPlayerViewController: PUIPlayerViewDelegate {

    func playerViewDidSelectToggleFullScreen(_ playerView: PUIPlayerView) {
        if let playerWindow = playerView.window as? PUIPlayerWindow {
            playerWindow.toggleFullScreen(self)
        } else {
            detach(forEnteringFullscreen: true)
        }
    }

    func playerViewDidSelectAddAnnotation(_ playerView: PUIPlayerView, at timestamp: Double) {

    }

    private func snapshotPlayer(completion: @escaping (CGImage?) -> Void) {
        playerView.snapshotPlayer(completion: completion)
    }

    func playerViewWillExitPictureInPictureMode(_ playerView: PUIPlayerView, reason: PUIPiPExitReason) {
        playerWillExitPictureInPicture?(reason)
    }

    func playerViewWillEnterPictureInPictureMode(_ playerView: PUIPlayerView) {
        
    }

    func playerViewDidSelectLike(_ playerView: PUIPlayerView) {
        
    }

}

extension VideoPlayerViewController: PUIPlayerViewAppearanceDelegate {

    func playerViewShouldShowSubtitlesControl(_ playerView: PUIPlayerView) -> Bool {
       return true
    }

    func playerViewShouldShowPictureInPictureControl(_ playerView: PUIPlayerView) -> Bool {
       return false
    }

    func playerViewShouldShowSpeedControl(_ playerView: PUIPlayerView) -> Bool {
        return true
    }

    func playerViewShouldShowAnnotationControls(_ playerView: PUIPlayerView) -> Bool {
        return false
    }

    func playerViewShouldShowBackAndForwardControls(_ playerView: PUIPlayerView) -> Bool {
        return true
    }

    func playerViewShouldShowExternalPlaybackControls(_ playerView: PUIPlayerView) -> Bool {
        return true
    }

    func playerViewShouldShowFullScreenButton(_ playerView: PUIPlayerView) -> Bool {
        return false
    }

    func playerViewShouldShowTimelineView(_ playerView: PUIPlayerView) -> Bool {
        return true
    }

    func playerViewShouldShowTimestampLabels(_ playerView: PUIPlayerView) -> Bool {
        return true
    }

    func playerViewShouldShowBackAndForward30SecondsButtons(_ playerView: PUIPlayerView) -> Bool {
        return true
    }
}
