//
//  TitleBarViewController.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class TitleBarViewController: NSViewController {
    private lazy var filterView = TagFilterViewController()

    private lazy var searchBar: NSSearchField = {
        let v = NSSearchField()

        v.focusRingType = .none
        v.translatesAutoresizingMaskIntoConstraints = false
        v.placeholderString = "Search"
        v.sendsWholeSearchString = true
        v.sendsSearchStringImmediately = false
        v.target = self
        v.action = #selector(self.didSearch)

        return v
    }()

    private lazy var clearButton: NSButton = {
        let b = NSButton(title: "Clear", target: TagSyncService.shared, action: #selector(TagSyncService.shared.clear))
        b.alphaValue = 0

        return b
    }()

    private lazy var stackView: NSStackView = {
        return NSStackView(views: [self.filterView.view, self.clearButton, self.searchBar])
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        listenForKeyEvents()
    }

    override func loadView() {
        view = NSView()
        view.addSubview(stackView)

        addChild(filterView)

        view.height(70)
        stackView.edgesToSuperview(insets: .init(top: 30, left: 15, bottom: 15, right: 15))
        searchBar.width(300)
        searchBar.trailing(to: stackView)
        clearButton.trailingToLeading(of: searchBar, offset: -10)
    }

    func listenForKeyEvents() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard MainCoordinator.keyEventsActive == true else { return event }
            guard let flags = NSApp.currentEvent?.modifierFlags else { return event }

            switch Int( event.keyCode) {
            case  3, 37:
                guard flags.contains(.command) else { return event}
                self.searchBar.becomeFirstResponder()

                return nil
            case 53:
                TagSyncService.shared.clear()

                return nil
            case 125:
                if self.searchBar.currentEditor() == self.searchBar.window?.firstResponder {
                    self.searchBar.resignFirstResponder()

                    if let mainWindow = self.view.window?.nextResponder as? MainWindowController {
                        if let mainViewController = mainWindow.contentViewController as? MainViewController {
                            let v = mainViewController.mainSplitViewController.listViewController.tableView
                            mainWindow.window?.makeFirstResponder(v)
                        }
                    }

                    return nil

                } else {
                    return event
                }
            default:
                return event
            }
        }
    }

    @objc private func didSearch() {
        let searchTerm = searchBar.stringValue

        guard !searchTerm.replacingOccurrences(of: " ", with: "").isEmpty else {
            searchBar.stringValue = ""

            return
        }

        if !searchTerm.isEmpty {
            searchBar.stringValue = ""

            LoggingHelper.register(event: .searchFor, info: ["term": searchTerm])

            var tag = TagModel(title: searchTerm, isActive: true)
            TagSyncService.shared.handleTag(&tag)
        }
    }
}

