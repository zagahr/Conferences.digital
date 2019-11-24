//
//  Segment.swift
//  Conferences
//
//  Created by Timon Blask on 23/11/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

protocol Segment: NSView {
    var isActive: Bool { get set }
    var title: String { get }
    var onClick: (String) -> Void { get }
    var size: SegmentElement.Size { get }
}

final class SegmentElement: NSView, Segment {

    // MARK: - Types

    enum Size: CGFloat {
        case space = 1
        case small = 30
        case medium = 100
        case large = 150
    }

    // MARK: - Properties

    var onClick: (String) -> Void

    var isActive: Bool = false {
        didSet {
            updateBackgroundColor()
        }
    }

    let title: String

    var size: Size

    private lazy var titleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .primaryText
        l.lineBreakMode = .byTruncatingTail

        return l
    }()

    // MARK: - Initialization

    init(_ title: String, onClick: @escaping (String) -> Void, size: Size) {
        self.title = title
        self.size = size

        let action = size != .space ? onClick : { _ in }
        self.onClick = action

        super.init(frame: .zero)
        

        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Method

    private func configureView() {
        wantsLayer = true

        layer?.cornerRadius = 7
        addSubview(titleLabel)
        titleLabel.centerInSuperview()
        titleLabel.stringValue = title

        width(size.rawValue)

        let click = NSClickGestureRecognizer(target: self, action: #selector(didTapCell))
        self.addGestureRecognizer(click)

        if size == .space {
            layer?.backgroundColor = NSColor.lightGray.cgColor
        }
    }

    private func updateBackgroundColor() {
        guard size != .space else {
            return
        }

        if isActive {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.4
                ctx.allowsImplicitAnimation = true

                layer?.backgroundColor = NSColor.listBackground.cgColor

                self.layoutSubtreeIfNeeded()
            }, completionHandler: nil)
        } else {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.4
                ctx.allowsImplicitAnimation = true
                layer?.backgroundColor = NSColor.clear.cgColor

                self.layoutSubtreeIfNeeded()
            }, completionHandler: nil)
        }
    }

    @objc func didTapCell() {
        onClick(title)
    }

}
