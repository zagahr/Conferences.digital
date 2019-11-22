//
//  ListViewController.swift
//  Conferences
//
//  Created by Timon Blask on 12/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa
import TinyConstraints

class ListViewController: NSViewController {

    private lazy var headerView: NSView = {
        let v = ListViewHeaderView()

        v.height(100)
        return v
    }()

    lazy var tableView: NSTableView = {
        let v = NSTableView()

        v.allowsEmptySelection = false
        v.focusRingType = .none
        v.allowsMultipleSelection = true
        v.backgroundColor = NSColor.listBackground
        v.headerView = nil
        v.autoresizingMask = [.width, .height]
        v.selectionHighlightStyle = .regular

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "session"))
        v.addTableColumn(column)

        return v
    }()

    lazy var scrollView: NSScrollView = {
        let v = NSScrollView()

        v.focusRingType = .none
        v.borderType = .noBorder
        v.documentView = self.tableView
        v.hasVerticalScroller = true
        v.hasHorizontalScroller = false
        v.hasVerticalScroller = false

        return v
    }()

    override func loadView() {
        view = NSView()

        view.addSubview(headerView)
        view.addSubview(scrollView)

        headerView.edgesToSuperview(excluding: .bottom)
        scrollView.edgesToSuperview(excluding: .top)
        scrollView.topToBottom(of: headerView)
        
        scrollView.width(min: 320, max: 675, priority: .defaultHigh, isActive: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        view.window?.makeFirstResponder(tableView)
    }

    @objc func reloadActiveCell(_ notification: Notification) {
        tableView.reloadData(forRowIndexes: selectedAndClickedRowIndexes(), columnIndexes: IndexSet(integer: 0))

        guard let shouldReloadDetailVC = notification.object as? Bool else { return }
        guard shouldReloadDetailVC == true else { return }
        guard let dataSource = tableView.dataSource as? ListViewDataSource else { return }

        if let index = selectedAndClickedRowIndexes().first {
            dataSource.didSelectIndex(at: index)
        }
    }
}

extension ListViewController: NSMenuItemValidation {

    fileprivate enum ContextualMenuOption: Int {
        case watched = 1000
        case unwatched = 1001
        case addToWatchlist = 1002
        case removeFromWatchlist = 1003
    }

    func selectedAndClickedRowIndexes() -> IndexSet {
        let clickedRow = tableView.clickedRow
        let selectedRowIndexes = tableView.selectedRowIndexes

        if clickedRow < 0 || selectedRowIndexes.contains(clickedRow) {
            return selectedRowIndexes
        } else {
            return IndexSet(integer: clickedRow)
        }
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        for row in selectedAndClickedRowIndexes() {
            guard
                let dataSource = tableView.dataSource as? ListViewDataSource,
                let talk = dataSource.talks[row] as? TalkModel else {
                return false
            }


            if shouldEnableMenuItem(menuItem: menuItem, talk: talk) { return true}
        }

        return false
    }

    private func shouldEnableMenuItem(menuItem: NSMenuItem, talk: TalkModel) -> Bool {
        switch menuItem.option {
        case .watched:
            let canMarkAsWatched = talk.progress == nil || talk.progress?.watched == false

            return canMarkAsWatched
        case .unwatched:
            return talk.progress?.watched == true || talk.progress?.relativePosition != 0
        case .addToWatchlist:
            return !talk.onWatchlist
        case .removeFromWatchlist:
            return talk.onWatchlist
        }
    }

    private func setupContextualMenu() {
        let contextualMenu = NSMenu(title: "TableView Menu")

        let watchedMenuItem = NSMenuItem(title: "Mark as Watched", action: #selector(tableViewMenuItemClicked(_:)), keyEquivalent: "")
        watchedMenuItem.option = .watched
        contextualMenu.addItem(watchedMenuItem)

        let unwatchedMenuItem = NSMenuItem(title: "Mark as Unwatched", action: #selector(tableViewMenuItemClicked(_:)), keyEquivalent: "")
        unwatchedMenuItem.option = .unwatched
        contextualMenu.addItem(unwatchedMenuItem)

        contextualMenu.addItem(.separator())

        let favoriteMenuItem = NSMenuItem(title: "Add to Watchlist", action: #selector(tableViewMenuItemClicked(_:)), keyEquivalent: "")
        favoriteMenuItem.option = .addToWatchlist
        contextualMenu.addItem(favoriteMenuItem)

        let removeFavoriteMenuItem = NSMenuItem(title: "Remove from Watchlist", action: #selector(tableViewMenuItemClicked(_:)), keyEquivalent: "")
        removeFavoriteMenuItem.option = .removeFromWatchlist
        contextualMenu.addItem(removeFavoriteMenuItem)


        tableView.menu = contextualMenu
    }

    @objc private func tableViewMenuItemClicked(_ menuItem: NSMenuItem) {
        LoggingHelper.register(event: .rightClickonTable )

        var talks = [TalkModel]()
        guard let dataSource = tableView.dataSource as? ListViewDataSource else { return }

        selectedAndClickedRowIndexes().forEach { row in
            guard let talk = dataSource.talks[row] as? TalkModel else { return }
            talks.append(talk)
        }

        guard !talks.isEmpty else { return }

        switch menuItem.option {
        case .watched:
            print("watched")
        case .unwatched:
            print("unwatched")
        case .addToWatchlist:
            print("addToWatchlist")
        case .removeFromWatchlist:
            print("removeFromWatchlist")
        }

        self.tableView.reloadData(forRowIndexes: selectedAndClickedRowIndexes(), columnIndexes: IndexSet(integer: 0))

        if let index = selectedAndClickedRowIndexes().first {
            dataSource.didSelectIndex(at: index)
        }
    }
}

private extension NSMenuItem {

    var option: ListViewController.ContextualMenuOption {
        get {
            guard let value = ListViewController.ContextualMenuOption(rawValue: tag) else {
                fatalError("Invalid ContextualMenuOption: \(tag)")
            }

            return value
        }
        set {
            tag = newValue.rawValue
        }
    }

}
