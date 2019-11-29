//
//  MainSplitViewController.swift
//  Conferences
//
//  Created by Timon Blask on 12/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class SplitViewController: NSSplitViewController {
    weak var coordinateDelegate: SplitViewCoordinator?

    lazy var listViewController: ListViewController = {
        let vc = ListViewController()
        vc.tableView.delegate = self.coordinateDelegate?.listDataDelegate
        vc.tableView.dataSource = self.coordinateDelegate?.listDataDelegate

        return vc
    }()

    lazy var detailViewController: DetailSplitViewController = {
        let vc = DetailSplitViewController()
        vc.shelfController.delegate = self.coordinateDelegate

        return vc
    }()

    private var listItem: NSSplitViewItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = false
        listItem = NSSplitViewItem(sidebarWithViewController: listViewController)
        listItem?.canCollapse = true

        let detailItem = NSSplitViewItem(viewController: detailViewController)

        addSplitViewItem(listItem!)
        addSplitViewItem(detailItem)
        
        listViewController.view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        detailViewController.view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        detailViewController.view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        splitView.setValue(NSColor.listBackground, forKey: "dividerColor")
        splitView.dividerStyle = .thick
        splitView.autosaveName = "SplitView"
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let width = listItem?.viewController.view.frame.width, width == 320 {
            splitView.setPosition(480, ofDividerAt: 0)
        }
    }
}

