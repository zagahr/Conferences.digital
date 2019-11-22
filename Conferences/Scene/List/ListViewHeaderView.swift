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

    private lazy var container: NSView = {
        let v = NSView()

        v.wantsLayer = true
        v.layer?.cornerRadius = 4
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
        v.font = .systemFont(ofSize: 17)
        v.usesSingleLineMode = true

        return v
    }()

    private lazy var segmentControl: NSSegmentedControl = {
        let control = NSSegmentedControl()

        return control
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

        addSubview(container)
        addSubview(segmentControl)
        container.addSubview(searchBar)
        searchBar.widthToSuperview()
        searchBar.centerInSuperview()

        segmentControl.bottom(to: searchBar)
        segmentControl.leftToSuperview()
        segmentControl.rightToSuperview()
        segmentControl.height(40
        )

        container.centerYToSuperview()
        container.height(25)

        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
        ])
    }

    @objc private func didSaaaearch(_ sender: Any?) {
        print("claer")
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
        
        NotificationCenter.default.post(notification)
    }

}
