//
//  TitleTableCellView.swift
//  Conferences
//
//  Created by Timon Blask on 12/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

class TitleTableCellView: NSTableCellView {

    private lazy var conferenceView = ConferenceView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    override func layout() {
        super.layout()

        if let superview = self.superview as? NSTableRowView {
            superview.isGroupRowStyle = false
        //    superview.selectionHighlightStyle = .none
       //     superview.backgroundColor = NSColor.panelBackground
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        
        addSubview(conferenceView)
        conferenceView.edgesToSuperview()
    }

    func configureView(with model: ConferenceModel) {

        conferenceView.configureView(with: model)
    }

}
