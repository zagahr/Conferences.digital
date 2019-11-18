//
//  DetailSplitViewController.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class DetailSplitViewController: NSSplitViewController {

    lazy var shelfController = ShelfViewController()
    lazy var summaryController = DetailSummaryViewController()

    private var listItem: NSSplitViewItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = false
        listItem = NSSplitViewItem(viewController: summaryController)
        listItem?.canCollapse = true

        let detailItem = NSSplitViewItem(viewController: shelfController)

        addSplitViewItem(detailItem)
        addSplitViewItem(listItem!)


        shelfController.view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        summaryController.view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        summaryController.view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        summaryController.view.setContentHuggingPriority(.defaultLow, for: .vertical)

        splitView.setValue(NSColor.black, forKey: "dividerColor")
        splitView.dividerStyle = .thick
        splitView.autosaveName = "DetailSplitView"
        splitView.isVertical = false
    }

    func configureView(with talk: TalkModel) {
        view.animator().alphaValue = 1

        shelfController.configureView(with: talk)
        summaryController.configureView(with: talk)
    }
}
