//
//  ListViewHeaderView.swift
//  Conferences
//
//  Created by Timon Blask on 15/11/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class SearchBar: NSSearchField {

    override var allowsVibrancy: Bool {
        return false
    }

}

final class ListViewHeaderView: NSView {

    private lazy var searchContainer: NSView = {
        let v = NSView()

        v.wantsLayer = true
        v.layer?.cornerRadius = 7
        v.layer?.backgroundColor = NSColor.windowBackground.cgColor

        return v
    }()

    private lazy var searchBar: SearchBar = {
        let v = SearchBar()

        v.focusRingType = .none
        v.target = self
        v.action = #selector(self.didSearch)
        v.alignment = .center
        v.isBordered = false
        v.textColor = .white
        v.placeholderString = "Search"
        v.font = .systemFont(ofSize: 15)
        v.usesSingleLineMode = true

        return v
    }()

    private lazy var segmentControl: SegmentControl = {
        let control = SegmentControl()

        return control
    }()

    private lazy var stackView: NSStackView = {
        let v = NSStackView(views: [searchContainer, segmentControl])
        v.distribution = .fillEqually
        v.spacing = 10
        v.orientation = .vertical

        return v
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.listBackground.cgColor

        addSubview(stackView)

        searchContainer.addSubview(searchBar)
        searchBar.widthToSuperview()
        searchBar.centerInSuperview()
        stackView.centerYToSuperview()
        stackView.leftToSuperview(offset: 20)
        stackView.rightToSuperview(offset: -10)
        stackView.height(70)

        segmentControl.setSegments([
            (title: "All", size: .large),
            (title: "", size: .space),
            (title: "Watchlist", size: .large)
        ])
    }

    @objc private func didSearch() {
        let searchTerm = searchBar.stringValue

        if let config = try? JSONDecoder().decode(Config.self, from: searchTerm.data(using: .utf8) ?? Data()) {

            ConfigManager.set(config)
            searchBar.stringValue = ""

            return
        }

        LoggingHelper.register(event: .searchFor, info: ["term": searchTerm])
        
        let notification = Notification(name: Notification.Name.UserDidSearch, object: nil, userInfo: ["searchTerm": searchTerm])

        segmentControl.didSelectCell("All")
        NotificationCenter.default.post(notification)
    }

}
