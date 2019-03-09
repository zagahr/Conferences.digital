//
//  TagFilterViewController.swift
//  Conferences
//
//  Created by Timon Blask on 04/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class TagFilterViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        observe()
        updateTags()
    }

    func observe() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTags), name: .refreshTagView, object: nil)
    }

    override func loadView() {
        view = NSView(frame: .zero)
        view.addSubview(scrollView)

        scrollView.edgesToSuperview()
    }

    private lazy var scrollView: NSScrollView = {
        let v = NSScrollView()

        v.focusRingType = .none
        v.borderType = .noBorder
        v.documentView = self.tagStackView
        v.verticalScrollElasticity = .none
        v.horizontalScrollElasticity = .none
        v.hasVerticalScroller = false
        v.hasHorizontalScroller = false
        v.drawsBackground = true
        v.backgroundColor = NSColor.elementBackground

        return v
    }()

    private lazy var tagStackView: NSStackView = {
        let v = NSStackView(views: [])

        v.spacing = 10

        return v
    }()


    @objc private func updateTags() {
        let tags = TagSyncService.shared.tags

        if let stackView = self.view.superview as? NSStackView,
            let clearButton = stackView.arrangedSubviews.first(where: { $0 as? NSButton != nil }) {

            if let _ = tags.first(where: { $0.isActive }) {
                clearButton.animator().alphaValue = 1
            } else {
                clearButton.animator().alphaValue = 0
            }
        }


        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        tags.forEach ({ (tag) in
            let view = TagView(tag: tag)
            let control = PUIButton()

            control.addSubview(view)
            view.edgesToSuperview()

            control.target = view
            control.action = #selector(view.updateState)

            let width = control.width(view.fittingSize.width)

            view.onClicked = { [] in
                width.constant = view.fittingSize.width

                var copy = tag
                copy.isActive.toggle()

                TagSyncService.shared.handleTag(&copy)
            }

            tagStackView.addArrangedSubview(control)
        })
    }
}
