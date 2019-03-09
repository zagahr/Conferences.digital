//
//  ShelfViewController.swift
//  Conferences
//
//  Created by Timon Blask on 12/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

protocol ShelfViewControllerDelegate: class {
    func shelfViewControllerDidSelectPlay(_ controller: ShelfViewController)
}

class ShelfViewController: NSViewController {
    var playerController: Playable? {
        didSet {
            guard let playerController = playerController else { return }

            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParent()

            NSAnimationContext.runAnimationGroup({ _ in
                playerContainer.animator().isHidden = false
                playerContainer.animator().alphaValue = 1
            }, completionHandler: nil)

            playerContainer.addSubview(playerController.view)
            playerController.view.edgesToSuperview()

            addChild(playerController)

            playerController.play()
        }
    }

    private weak var imageDownloadOperation: Operation?

    weak var delegate: ShelfViewControllerDelegate?

    private lazy var previewImage = AspectFillImageView()
    private lazy var playerContainer = NSView()

    private lazy var playButton: VibrantButton = {
        let b = VibrantButton(frame: .zero)

        b.title = "Play"
        b.target = self
        b.action = #selector(play)

        return b
    }()

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = .black
        
        view.addSubview(previewImage)
        view.addSubview(playButton)
        view.addSubview(playerContainer)

        playButton.center(in: view)
        previewImage.edgesToSuperview(insets: .init(top: 20, left: 20, bottom: 20, right: 20))
        playerContainer.edgesToSuperview()

        view.height(min: 300, max: nil, priority: .defaultHigh, isActive: true)
    }

    func configureView(with talk: TalkModel) {
        playButton.state = .off

        guard talk.currentlyPlaying == false else {
            NSAnimationContext.runAnimationGroup({ _ in
                playerContainer.animator().isHidden = false
                playerContainer.animator().alphaValue = 1
            }, completionHandler: nil)
            return
        }

        NSAnimationContext.runAnimationGroup({ _ in
            playerContainer.animator().alphaValue = 0
        }, completionHandler: {
            self.playerContainer.isHidden = true
        })

        previewImage.image = NSImage(named: "placeholder")

        guard let imageUrl = URL(string: talk.previewImage) else { return }

        self.imageDownloadOperation?.cancel()

        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 150) { [weak self] url, original, _ in
            guard url == imageUrl, original != nil else { return }

            self?.previewImage.image = original
        }
    }

    @objc private func play(_ sender: Any?) {
        playerContainer.subviews.forEach {$0.removeFromSuperview() }
        self.delegate?.shelfViewControllerDidSelectPlay(self)
    }
}
