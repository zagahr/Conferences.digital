//
//  LoadingView.swift
//  Conferences
//
//  Created by Timon Blask on 12/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

class LoadingView: NSView {
     var onClicked: (() -> Void)?

    private lazy var backgroundView: NSVisualEffectView = {
        let v = NSVisualEffectView()

        v.material = .ultraDark
        v.blendingMode = .withinWindow
        v.translatesAutoresizingMaskIntoConstraints = false
        v.state = .active

        return v
    }()

    private lazy var titleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textColor = .primaryText
        l.cell?.backgroundStyle = .dark
        l.lineBreakMode = .byTruncatingTail

        return l
    }()


    lazy var reloadButton: NSButton = NSButton(title: "Reload", target: self, action: #selector(reload))

    private lazy var errorStackView: NSStackView = {
        let v = NSStackView(views: [self.titleLabel, self.reloadButton])

        v.orientation = .vertical
        v.distribution = .fill
        v.spacing = 24
        v.isHidden = true

        return v
    }()

    private lazy var spinner: NSProgressIndicator = {
        let p = NSProgressIndicator()

        p.isIndeterminate = true
        p.style = .spinning
        p.startAnimation(self)
        p.appearance = NSAppearance(named: NSAppearance.Name(rawValue: "WhiteSpinner"))

        return p
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true

        addSubview(backgroundView)

        backgroundView.addSubview(spinner)
        backgroundView.addSubview(errorStackView)

        backgroundView.edgesToSuperview()
        spinner.center(in: backgroundView)

        errorStackView.center(in: backgroundView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func show(_ error: APIError) {
        spinner.isHidden = true
        errorStackView.isHidden = false
        titleLabel.stringValue = error.message
    }

    func show() {
        spinner.isHidden = false
        alphaValue = 0
        autoresizingMask = [.width, .height]
        spinner.startAnimation(nil)

        NSAnimationContext.runAnimationGroup({ _ in
            self.alphaValue = 1
            NSApplication.shared.mainWindow?.toolbar?.isVisible = false
        }, completionHandler: nil)
    }

    func hide() {
        NSAnimationContext.runAnimationGroup({ _ in
            self.spinner.stopAnimation(nil)
            self.alphaValue = 0
        }, completionHandler: {
            self.removeFromSuperview()
        })
    }

    @objc func reload() {
        spinner.isHidden = false
        errorStackView.isHidden = true

        onClicked?()
    }

    override func mouseDown(with event: NSEvent) {

    }
}
