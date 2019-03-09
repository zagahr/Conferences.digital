//
//  SpeakerView.swift
//  Conferences
//
//  Created by Timon Blask on 04/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class SpeakerView: NSView {
    private var speaker: SpeakerModel?
    private weak var imageDownloadOperation: Operation?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var profilePicture: AspectFillImageView = {
        let v = AspectFillImageView()
        v.isRounded = true
        v.layer?.borderWidth = 2
        v.layer?.borderColor = NSColor.activeColor.cgColor
        v.height(100)
        v.width(100)

        return v
    }()

    private lazy var aboutLabel: AutoLayoutTextField = {
        let l = AutoLayoutTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryText

        l.isSelectable = true
        l.lineBreakMode = .byWordWrapping
        l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        l.allowsDefaultTighteningForTruncation = true
        l.maximumNumberOfLines = 20

        return l
    }()

    private lazy var twitterButton: ImageButton = {
        let b = ImageButton(frame: .zero)
        b.height(25)
        b.width(25)
        b.image = #imageLiteral(resourceName: "twitter")
        b.target = self
        b.action = #selector(openTwitter)
        b.toolTip = "Open Twitter"

        return b
    }()

    private lazy var githubButton: ImageButton = {
        let b = ImageButton(frame: .zero)
        b.height(25)
        b.width(25)
        b.image = #imageLiteral(resourceName: "github")
        b.target = self
        b.action = #selector(openGithub)
        b.toolTip = "Open GitHub"

        return b
    }()


    private lazy var titleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .primaryText
        l.lineBreakMode = .byTruncatingTail

        let click = NSClickGestureRecognizer(target: self, action: #selector(showMoreByUser))
        l.addGestureRecognizer(click)

        return l
    }()

    private lazy var subtitleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    private lazy var socialMediaStackView: NSStackView = {
        let v = NSStackView(views: [self.twitterButton, self.githubButton])

        v.distribution = .fillProportionally
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
        let v = NSStackView(views: [self.profilePicture, self.informationStackView])

        v.distribution = .fill
        v.spacing = 15
        v.height(120)

        return v
    }()

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [self.topStackView, self.aboutLabel])

        self.topStackView.width(to: v)

        v.orientation = .vertical
        v.spacing = 10

        return v
    }()

    private func configureView() {
        wantsLayer = true

        layer?.cornerRadius = 10
        layer?.backgroundColor = NSColor.elementBackground.cgColor

        addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 15, left: 15, bottom: 15, right: 15))

        stackView.width(300)
    }

    func configureView(with model: SpeakerModel) {
        self.speaker = model
        titleLabel.stringValue = "\(model.firstname) \(model.lastname)"
        subtitleLabel.stringValue = "@\(model.twitter ?? model.github ?? "")"

        if subtitleLabel.stringValue == "@" {
            subtitleLabel.stringValue = ""
        }

        twitterButton.isHidden = model.twitter != nil ? false : true
        githubButton.isHidden = model.github != nil ? false : true

        aboutLabel.stringValue = model.about ?? ""
        aboutLabel.invalidateIntrinsicContentSize()
        guard let imageUrl = URL(string: model.image) else { return }

        self.imageDownloadOperation?.cancel()
        self.imageDownloadOperation = ImageDownloadCenter.shared.downloadImage(from: imageUrl, thumbnailHeight: 100) { [weak self] url, _, thumb in
            guard url == imageUrl, thumb != nil else { return }

            self?.profilePicture.image = thumb
        }
    }

    @objc func showMoreByUser() {
        let searchTerm = titleLabel.stringValue

        if !searchTerm.isEmpty {
            var tag = TagModel(title: searchTerm, isActive: true)
            TagSyncService.shared.handleTag(&tag)
        }
    }

    @objc func openTwitter() {
        guard let twitterHandle = self.speaker?.twitter else { return }

        LoggingHelper.register(event: .openSpeakerTwitter, info: ["speakerId": String(self.speaker!.id)])

        let twitterUrl = "https://twitter.com/\(twitterHandle)"
        if let url = URL(string: twitterUrl) {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func openGithub() {
        guard let githubHandle = self.speaker?.github else { return }

        LoggingHelper.register(event: .openSpeakerGithub, info: ["speakerId": String(self.speaker!.id)])

        let githubUrl = "https://github.com/\(githubHandle)"
        if let url = URL(string: githubUrl) {
            NSWorkspace.shared.open(url)
        }
    }

}
