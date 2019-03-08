//
//  ConferenceView.swift
//  Conferences
//
//  Created by Timon Blask on 06/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class ConferenceView: NSView {
    private var conference: ConferenceModel?
    private weak var imageDownloadOperation: Operation?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var logo: AspectFillImageView = {
        let v = AspectFillImageView()
        v.isRounded = true
        v.layer?.borderWidth = 2
        v.layer?.borderColor = NSColor.activeColor.cgColor
        v.height(100)
        v.width(100)

        return v
    }()

    private lazy var aboutLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryText
        
        l.isSelectable = true
        l.lineBreakMode = .byWordWrapping
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        l.alignment = .left
        l.allowsDefaultTighteningForTruncation = true
        l.maximumNumberOfLines = 20
        return l
    }()

    private lazy var websiteButton: ImageButton = {
        let b = ImageButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.image = #imageLiteral(resourceName: "internet")
        b.target = self
        b.action = #selector(openHomepage)
        b.toolTip = "Open Homepage"

        return b
    }()

    private lazy var twitterButton: ImageButton = {
        let b = ImageButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.image = #imageLiteral(resourceName: "twitter")
        b.target = self
        b.action = #selector(openTwitter)
        b.toolTip = "Open Twitter"

        return b
    }()

    private lazy var eventButton: ImageButton = {
        let b = ImageButton(frame: .zero)
        b.height(20)
        b.width(20)
        b.image = #imageLiteral(resourceName: "ticket")
        b.target = self
        b.action = #selector(openHomepage)
        b.toolTip = "Show tickets"

        return b
    }()


    private lazy var titleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .primaryText
        l.cell?.backgroundStyle = .dark
        l.lineBreakMode = .byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return l
    }()

    private lazy var subtitleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryText
        l.cell?.backgroundStyle = .dark
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var socialMediaStackView: NSStackView = {
        let v = NSStackView(views: [self.websiteButton, self.twitterButton, self.eventButton])
        
        v.distribution = .fill
        v.spacing = 10

        return v
    }()

    private lazy var textStackView: NSStackView = {
        let v = NSStackView(views: [self.titleLabel, self.subtitleLabel])

        v.orientation = .vertical
        v.alignment = .leading
        v.distribution = .fill
        v.spacing = 0

        return v
    }()

    private lazy var informationStackView: NSStackView = {
        let spacing = NSView()
        spacing.wantsLayer = true
        spacing.layer?.backgroundColor = NSColor.activeColor.cgColor
        spacing.height(1)

        let v = NSStackView(views: [self.textStackView, spacing, self.socialMediaStackView])

        v.orientation = .vertical
        v.alignment = .leading
        v.distribution = .fill
        v.spacing = 10

        return v
    }()

    private lazy var topStackView: NSStackView = {
        let v = NSStackView(views: [self.logo, self.informationStackView])

        v.alignment = .top
        v.distribution = .fill
        v.spacing = 15

        return v
    }()

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [self.topStackView, self.aboutLabel])

        self.topStackView.width(to: v)

        v.alignment = .top
        v.orientation = .vertical
        v.distribution = .equalCentering

        return v
    }()


    private func configureView() {
        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 10
        containerView.layer?.backgroundColor = NSColor.elementBackground.cgColor
        addSubview(containerView)
        containerView.edgesToSuperview()

        containerView.addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 15, left: 15, bottom: 15, right: 15))
    }

    func configureView(with model: ConferenceModel) {
        self.conference = model

        titleLabel.stringValue = model.name
        subtitleLabel.stringValue = model.location

        twitterButton.isHidden = model.organisator.twitter != nil ? false : true
        eventButton.isHidden = model.organisator.nextEvent != nil ? false : true
        websiteButton.isHidden = false

        aboutLabel.stringValue = model.about

        guard let imageUrl = URL(string: model.logo) else { return }

        self.imageDownloadOperation?.cancel()
        self.logo.image = NSImage(named: "placeholder-square")
        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 100) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }
            self?.logo.isHidden = false
            self?.logo.image = thumb
        }
    }

    @objc func openHomepage() {
        if let url = URL(string: self.conference?.url ?? "") {
            LoggingHelper.register(event:.openConferenceHomepage, info: ["conferenceId": String(self.conference!.id)])
            NSWorkspace.shared.open(url)
        }
    }

    @objc func openTwitter() {
        guard let twitterHandle = self.conference?.organisator.twitter else { return }

        LoggingHelper.register(event: .openConferenceTwitter, info: ["handle": twitterHandle])

        let twitterUrl = "https://twitter.com/\(twitterHandle)"
        if let url = URL(string: twitterUrl) {
            NSWorkspace.shared.open(url)
        }
    }

}

