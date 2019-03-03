//
//  VibrantButton.swift
//  Conferences
//
//  Created by Timon Blask on 23/04/17.
//  Copyright © 2017 Guilherme Rambo. All rights reserved.
//

import Cocoa

class VibrantButton: NSView {

    var target: Any?
    var action: Selector?

    var disableAnimation: Bool = false

    var title: String? {
        didSet {
            titleLabel.stringValue = title ?? ""
            sizeToFit()
        }
    }

    var state: NSControl.StateValue = .off {
        didSet {
            if !disableAnimation {
                if state == .on {
                    title = ""
                    spinner.isHidden = false
                    spinner.startAnimation(nil)
                } else {
                    title = "Play"
                    spinner.isHidden = true
                    spinner.startAnimation(nil)
                }
            }
        }
    }

    private lazy var spinner: NSProgressIndicator = {
        let p = NSProgressIndicator()
        p.isHidden = true
        p.isIndeterminate = true
        p.style = .spinning
        p.appearance = NSAppearance(named: NSAppearance.Name(rawValue: "WhiteSpinner"))

        return p
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.masksToBounds = true
        layer?.cornerRadius = 10

        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var titleLabel: NSTextField = {
        let l = NSTextField(labelWithString: "")
        l.font = .systemFont(ofSize: 18)
        l.textColor = .inactiveColor
        l.lineBreakMode = .byTruncatingTail
        l.alignment = .center

        return l
    }()

    private lazy var vfxView: NSView = {
        let v = NSView(frame: .zero)
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.inactiveButton.cgColor

        return v
    }()

    private func buildUI() {
        addSubview(vfxView)
        vfxView.addSubview(titleLabel)
        vfxView.addSubview(spinner)

        vfxView.edgesToSuperview()
        titleLabel.centerInSuperview()
        spinner.centerInSuperview()

        sizeToFit()
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: titleLabel.intrinsicContentSize.width + 74,
                      height: titleLabel.intrinsicContentSize.height + 24)
    }

    func sizeToFit() {
        titleLabel.sizeToFit()
        frame = NSRect(origin: frame.origin, size: intrinsicContentSize)

        self.trackingAreas.forEach { removeTrackingArea($0) }
        self.addTrackingRect(bounds, owner: self, userData: nil, assumeInside: true)
    }

    override func mouseEntered(with event: NSEvent) {
        titleLabel.textColor = .activeColor
        vfxView.layer?.backgroundColor = NSColor.activeButton.cgColor
    }

    override func mouseExited(with event: NSEvent) {
        titleLabel.textColor = .inactiveColor
        vfxView.layer?.backgroundColor = NSColor.inactiveButton.cgColor
    }

    override func mouseDown(with event: NSEvent) {
        state = .on
    }

    override func mouseUp(with event: NSEvent) {
        if let target = target, let action = action {
            NSApp.sendAction(action, to: target, from: self)
        }

        //state = .off
    }

}

public final class ImageButton: NSControl {

    public var isToggle = false

    public var activeTintColor: NSColor = .activeColor {
        didSet {
            needsDisplay = true
        }
    }

    public var tintColor: NSColor = .inactiveColor {
        didSet {
            needsDisplay = true
        }
    }

    public var state: NSControl.StateValue = .off {
        didSet {
            needsDisplay = true
        }
    }

    public var showsMenuOnLeftClick = false
    public var showsMenuOnRightClick = false
    public var sendsActionOnMouseDown = false

    public var image: NSImage? {
        didSet {
            guard let image = image else { return }

            if image.isTemplate {
                maskImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
            } else {
                maskImage = nil
            }

            invalidateIntrinsicContentSize()
        }
    }

    public var alternateImage: NSImage? {
        didSet {
            guard let alternateImage = alternateImage else { return }

            if alternateImage.isTemplate {
                alternateMaskImage = alternateImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
            } else {
                alternateMaskImage = nil
            }

            invalidateIntrinsicContentSize()
        }
    }

    private var maskImage: CGImage? {
        didSet {
            needsDisplay = true
        }
    }

    private var alternateMaskImage: CGImage? {
        didSet {
            needsDisplay = true
        }
    }

    public override func draw(_ dirtyRect: NSRect) {
        if let maskImage = maskImage {
            if let alternateMaskImage = alternateMaskImage, state == .on {
                drawMask(alternateMaskImage)
            } else {
                drawMask(maskImage)
            }
        } else {
            if let alternateImage = alternateImage, state == .on {
                drawImage(alternateImage)
            } else {
                drawImage(image)
            }
        }
    }

    private func drawMask(_ maskImage: CGImage) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        ctx.clip(to: bounds, mask: maskImage)

        if shouldDrawHighlighted || shouldAlwaysDrawHighlighted {
            ctx.setFillColor(activeTintColor.cgColor)
        } else if !isEnabled {
            let color = shouldAlwaysDrawHighlighted ? activeTintColor : tintColor
            ctx.setFillColor(color.cgColor)
        } else {
            ctx.setFillColor(tintColor.cgColor)
        }

        ctx.fill(bounds)

        if self.trackingAreas.count == 1 {
            self.addTrackingRect(bounds, owner: self, userData: nil, assumeInside: true)
        }
    }

    private func drawImage(_ image: NSImage?) {
        image?.draw(in: bounds)
    }

    public override var intrinsicContentSize: NSSize {
        if let image = image {
            return image.size
        } else {
            return NSSize(width: -1, height: -1)
        }
    }

    private var shouldDrawHighlighted: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public var shouldAlwaysDrawHighlighted: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public override var isEnabled: Bool {
        didSet {
            needsDisplay = true
        }
    }

    public override func mouseDown(with event: NSEvent) {
        guard isEnabled else { return }

        guard !showsMenuOnLeftClick else {
            showMenu(with: event)
            return
        }

        shouldDrawHighlighted = true

        if !sendsActionOnMouseDown {
            window?.trackEvents(matching: [.leftMouseUp, .leftMouseDragged], timeout: NSEvent.foreverDuration, mode: .eventTracking) { event, stop in
                if event?.type == .leftMouseUp {
                    self.shouldDrawHighlighted = false
                    stop.pointee = true
                }
            }
        }

        if let action = action, let target = target {
            if isToggle {
                state = (state == .on) ? .off : .on
            }
            NSApp.sendAction(action, to: target, from: self)
        }
    }

    public override func rightMouseDown(with event: NSEvent) {
        guard showsMenuOnRightClick else {
            return
        }
        showMenu(with: event)
    }

    private func showMenu(with event: NSEvent) {
        guard let menu = menu else { return }

        menu.popUp(positioning: nil, at: .zero, in: self)
    }

    public override var effectiveAppearance: NSAppearance {
        if #available(OSX 10.14, *) {
            return super.effectiveAppearance
        } else {
            return NSAppearance(named: .vibrantDark)!
        }
    }

    public override var allowsVibrancy: Bool {
        return true
    }

    public override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    public override func mouseEntered(with event: NSEvent) {
        shouldDrawHighlighted = true
    }

    public override func mouseExited(with event: NSEvent) {
        shouldDrawHighlighted = false
    }
}
