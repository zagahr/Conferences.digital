//
//  SegmentControl.swift
//  Conferences
//
//  Created by Timon Blask on 23/11/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

final class SegmentControl: NSView {

    // MARK: - Properties

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [])
        v.spacing = 8
        v.distribution = .gravityAreas
        return v
    }()

    private var segments: [Segment] = []

    // MARK: - Initialization

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        wantsLayer = true
        layer?.cornerRadius = 7
        layer?.backgroundColor = NSColor.windowBackground.cgColor
        addSubview(stackView)
        stackView.edgesToSuperview(insets: .init(top: 3, left: 3, bottom: 3, right: 3))
    }

    func setSegments( _ segments: [(title: String, size: SegmentElement.Size)]) {
        self.segments = segments.map { SegmentElement($0.title, onClick: didSelectCell, size: $0.size) }

        self.segments.first?.isActive = true

        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
        }

        self.segments.forEach { view in
            stackView.addArrangedSubview(view)
        }
    }

    func didSelectCell(_ identifier: String) {
        self.segments.forEach { segment in
            if segment.title == identifier {
                segment.isActive = true
            } else {
                segment.isActive = false
            }
        }

        let notification = Notification(name: Notification.Name.UserDidSearch, object: nil, userInfo: [identifier: true])

        NotificationCenter.default.post(notification)
    }

}
