//
//  WelcomeView.swift
//  Conferences
//
//  Created by Timon Blask on 25/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa
import Crashlytics

final class WelcomeView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "Welcome!")
        l.font = .systemFont(ofSize: 30, weight: .bold)
        l.cell?.backgroundStyle = .dark
        l.lineBreakMode = NSLineBreakMode.byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.allowsDefaultTighteningForTruncation = true
        l.maximumNumberOfLines = 1
        l.isSelectable = true
        l.allowsEditingTextAttributes = true

        return l
    }()

    private lazy var summaryLabel: AutoLayoutTextField = {
        let l = AutoLayoutTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 18)
        l.textColor = .secondaryText

        l.lineBreakMode = .byWordWrapping
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        l.allowsDefaultTighteningForTruncation = true
        l.maximumNumberOfLines = 20

        l.stringValue = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium"
        return l
    }()

    private lazy var backgroundView: NSView = {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = .black
        v.alphaValue = 0.9

        return v
    }()

    private lazy var containerView: NSView = {
        let v = NSView()

        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.panelBackground.cgColor
        v.layer?.cornerRadius = 20

        v.width(850)

        return v
    }()

    private lazy var startButton: VibrantButton = {
        let b = VibrantButton()
        b.disableAnimation = true
        b.title = "Start"
        b.target = self
        b.action = #selector(remove)

        return b
    }()

    private lazy var donationView: DonationView = {
        let v = DonationView()

        return v
    }()

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [self.titleLabel, self.summaryLabel, self.donationView, self.startButton])

        self.donationView.width(to: v)
        v.orientation = .vertical
        v.spacing = 30

        return v
    }()

    func configureView() {
        addSubview(backgroundView)
        addSubview(containerView)
        containerView.addSubview(stackView)


        stackView.edgesToSuperview(insets: .init(top: 30, left: 30, bottom: 30, right: 30))
        backgroundView.edgesToSuperview()
        containerView.centerInSuperview()
    }

    override func mouseDown(with event: NSEvent) {}
    override func scrollWheel(with event: NSEvent) {}

    @objc func remove() {
        UserDefaults.standard.setValue(true, forKey: "signup")

        Answers.logSignUp(withMethod: "Digits", success: true, customAttributes: nil)
        MainCoordinator.keyEventsActive = true
        
        NSAnimationContext.runAnimationGroup({ _ in
            self.animator().alphaValue = 0
        }, completionHandler: {
            self.removeFromSuperview()
        })
    }
}

final class DonationView: NSView {

    var onClick: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var donationButton: VibrantButton = {
        let b = VibrantButton()
        b.disableAnimation = true
        b.title = "Contribute to my Money Pool"
        b.target = self
        b.action = #selector(openDonation)

        return b
    }()

    private lazy var githubButton: VibrantButton = {
        let b = VibrantButton()
        b.disableAnimation = true
        b.title = "Star on GitHub"
        b.target = self
        b.action = #selector(openGithub)

        return b
    }()

    private lazy var leftLine: NSView = {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.inactiveColor.cgColor
        v.height(2)

        return v
    }()

    private lazy var rightLine: NSView = {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.inactiveColor.cgColor
        v.height(2)

        return v
    }()

    private lazy var orLabel: NSTextField = {
        let v = NSTextField(labelWithString: "or")
        v.textColor = .inactiveColor
        v.font = .systemFont(ofSize: 20, weight: .bold)

        return v
    }()

    private lazy var splitStackView: NSStackView = {
        let v = NSStackView(views: [self.leftLine, self.orLabel, self.rightLine])
        v.distribution = .equalCentering
        v.spacing = 30

        return v
    }()

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [self.githubButton, self.splitStackView, self.donationButton])

        v.orientation = .vertical
        v.distribution = .fillEqually
        v.spacing = 30

        return v
    }()

    func configureView() {
        addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 60, left: 60, bottom: 60, right: 60))
    }

    @objc func openDonation() {
        Answers.logCustomEvent(withName: "Opend Donate", customAttributes: nil)

        let donateUrl = "https://paypal.me/pools/c/8cCb9seyQi"
        if let url = URL(string: donateUrl) {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func openGithub() {
        Answers.logCustomEvent(withName: "Opend Star on GitHub", customAttributes: nil)

        let githubUrl = "https://github.com/zagahr/conferences-macos.app"
        if let url = URL(string: githubUrl) {
            NSWorkspace.shared.open(url)
        }
    }
}
