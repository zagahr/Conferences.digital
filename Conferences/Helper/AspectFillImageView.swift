//
//  ConferenceImageView.swift
//  Conferences
//
//  Created by Timon Blask on 14/05/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

class AspectFillImageView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isRounded = false {
        didSet {
            updateRoundness()
        }
    }

    var drawsBackground = true {
        didSet {
            backgroundLayer.isHidden = !drawsBackground
        }
    }

    override var isOpaque: Bool {
        return drawsBackground && !isRounded
    }

    var backgroundColor: NSColor = .clear {
        didSet {
            backgroundLayer.backgroundColor = backgroundColor.cgColor
        }
    }


    var image: NSImage? = nil {
        didSet {
            imageLayer.contents = image
        }
    }

    private lazy var backgroundLayer: WWDCLayer = {
        let l = WWDCLayer()

        l.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

        return l
    }()

    lazy var imageLayer: WWDCLayer = {
        let l = WWDCLayer()

        l.contentsGravity = .resizeAspect
        l.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        l.zPosition = 1

        return l
    }()

    private func configureView() {
        wantsLayer = true
        layer?.cornerRadius = 2
        layer?.masksToBounds = true

        backgroundLayer.frame = bounds
        imageLayer.frame = bounds

        layer?.addSublayer(backgroundLayer)
        layer?.addSublayer(imageLayer)
    }

    override func layout() {
        super.layout()

        updateRoundness()
    }

    override func makeBackingLayer() -> CALayer {
        return WWDCLayer()
    }


    private func updateRoundness() {
        guard let layer = layer else { return }

        layer.cornerRadius = isRounded ? layer.bounds.height / 2 : 0
    }

}
