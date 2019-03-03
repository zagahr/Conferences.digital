//
//  TitleTableCellView.swift
//  Conferences
//
//  Created by Timon Blask on 12/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

class TitleTableCellView: NSTableRowView  {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.panelBackground.set()
        dirtyRect.fill()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    override func layout() {
        super.layout()

        if let superview = self.superview as? NSTableRowView {
            superview.isGroupRowStyle = false
            superview.backgroundColor = NSColor.panelBackground
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var conferenceView: ConferenceView = {
        let v = ConferenceView()

        return v
    }()

    private func configureView() {
        addSubview(conferenceView)
        conferenceView.edgesToSuperview(insets: .init(top: 20, left: 20, bottom: 20, right: 20))
    }

    func configureView(with model: ConferenceModel) {
        conferenceView.configureView(with: model)
    }

}
