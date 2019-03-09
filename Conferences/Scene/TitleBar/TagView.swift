//
//  TagView.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

final class TagView: NSView {
    private var tagModel: TagModel
    var onClicked: (() -> Void)?

    init(tag: TagModel) {
        self.tagModel = tag
        super.init(frame: .zero)

        configureView()
        refreshView()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var label: NSTextField = {
        let v = NSTextField()
        v.font = .systemFont(ofSize: 14, weight: .semibold)
        v.alignment = .center
        v.isSelectable = false
        v.isBordered = false
        v.isBezeled = false
        v.drawsBackground = false
        v.maximumNumberOfLines = 1
        v.lineBreakMode = NSLineBreakMode.byTruncatingMiddle

        return v
    }()

    private lazy var cancelImage: NSImageView = {
        let v = NSImageView()
        v.image = NSImage(named: "cancel")
        v.height(15)
        v.width(15)
        v.isHidden = true

        return v
    }()

    private let tagCornerRadius: CGFloat = 5.0

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [self.label, self.cancelImage])

        v.orientation = .horizontal
        v.alignment = .centerY
        v.distribution = .equalCentering

        return v
    }()

    private func configureView() {
        wantsLayer = true

        addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 3, left: 5, bottom: 3, right: 5))

        layer?.cornerRadius = tagCornerRadius
        layer?.borderWidth = 1.8
    }

    private func refreshView() {
        let backgroundColor: NSColor = tagModel.isActive ? .inactiveColor : .elementBackground
        let textColor: NSColor = tagModel.isActive ? .elementBackground : .inactiveColor

        NSAnimationContext.runAnimationGroup({ _ in
            animator().layer?.borderColor = textColor.cgColor
            animator().layer?.backgroundColor = backgroundColor.cgColor
        }, completionHandler: nil)


        label.textColor = textColor
        label.stringValue = tagModel.title

        cancelImage.isHidden = !tagModel.isActive

        self.trackingAreas.forEach {self.removeTrackingArea($0) }
        self.addTrackingRect(NSRect(origin: .init(x: 0, y: 0), size: self.fittingSize), owner: self, userData: nil, assumeInside: true)
    }

    @objc func updateState() {
        tagModel.isActive.toggle()
        refreshView()

        onClicked?()
    }

    override func mouseEntered(with event: NSEvent) {
        let backgroundColor: NSColor = tagModel.isActive ? .activeColor : .elementBackground
        let textColor: NSColor = tagModel.isActive ? .elementBackground : .activeColor

        NSAnimationContext.runAnimationGroup({ _ in
            animator().layer?.borderColor = textColor.cgColor
            animator().layer?.backgroundColor = backgroundColor.cgColor
        }, completionHandler: nil)


        label.textColor = textColor
        label.stringValue = tagModel.title
    }

    override func mouseExited(with event: NSEvent) {
        let backgroundColor: NSColor = tagModel.isActive ? .inactiveColor : .elementBackground
        let textColor: NSColor = tagModel.isActive ? .elementBackground : .inactiveColor

        NSAnimationContext.runAnimationGroup({ _ in
            animator().layer?.borderColor = textColor.cgColor
            animator().layer?.backgroundColor = backgroundColor.cgColor
        }, completionHandler: nil)


        label.textColor = textColor
        label.stringValue = tagModel.title
    }
}
