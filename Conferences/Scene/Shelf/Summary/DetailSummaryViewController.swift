//
//  DetailSummaryViewController.swift
//  Conferences
//
//  Created by Timon Blask on 05/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

class DetailSummaryViewController: NSViewController {

    private lazy var titleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 40, weight: .bold)
        l.cell?.backgroundStyle = .dark
        l.lineBreakMode = NSLineBreakMode.byTruncatingTail
        l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        l.allowsDefaultTighteningForTruncation = true
        l.maximumNumberOfLines = 1
        l.textColor = .primaryText
        l.isSelectable = true
        // This prevents the text field from stripping attributes
        // during selection. 
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

        return l
    }()

    private lazy var contextLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 16)
        l.textColor = .tertiaryText
        l.cell?.backgroundStyle = .dark
        l.lineBreakMode = .byTruncatingTail
        l.allowsDefaultTighteningForTruncation = true

        return l
    }()

    lazy var speakerView: SpeakerView = SpeakerView()
    lazy var actionView: ActionView = ActionView()

    private lazy var labelStackView: NSStackView = {
        let v = NSStackView(views: [self.titleLabel, self.summaryLabel, self.contextLabel])

        v.orientation = .vertical
        v.alignment = .leading
        v.spacing = 24

        return v
    }()

    private lazy var leftStackView: NSStackView = {
        let v = NSStackView(views: [self.labelStackView, self.actionView])

        v.orientation = .vertical
        v.distribution = .fill
        v.alignment = .leading
        v.spacing = 24

        return v
    }()

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [self.leftStackView, self.speakerView])

        self.leftStackView.top(to: v)
        self.leftStackView.bottom(to: v)

        self.speakerView.top(to: v)
        self.speakerView.bottom(to: v)

        v.orientation = .horizontal
        v.alignment = .top
        v.distribution = .fill
        v.spacing = 24
        return v
    }()

    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.panelBackground.cgColor
        view.addSubview(stackView)

        stackView.edgesToSuperview(insets: .init(top: 20, left: 20, bottom: 20, right: 20))

        stackView.height(min: 220, max: 675, priority: .defaultHigh, isActive: true)
    }

    func configureView(with talk: TalkModel) {
        titleLabel.stringValue = talk.title
        summaryLabel.stringValue = talk.details ?? ""
        contextLabel.stringValue = talk.tags.filter { !$0.contains("2019") && !$0.contains("2018") && !$0.contains("2017") && !$0.contains("2016")}.joined(separator: " • ")

        contextLabel.isHidden = contextLabel.stringValue.isEmpty
        speakerView.configureView(with: talk.speaker)
        actionView.configureView(with: talk)
    }

}
