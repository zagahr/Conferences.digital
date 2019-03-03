//
//  MainWindowController.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class MainWindowController: NSWindowController {
    var didInitialResize = false

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("")
    }

    static var defaultRect: NSRect {
        return NSScreen.main?.visibleFrame.insetBy(dx: 50, dy: 120) ??
            NSRect(x: 0, y: 0, width: 1200, height: 600)
    }

    override func loadWindow() {
        let mask: NSWindow.StyleMask = [.titled, .resizable, .miniaturizable, .closable, .fullSizeContentView]
        let window = NSWindow(contentRect: MainWindowController.defaultRect, styleMask: mask, backing: .buffered, defer: false)

        window.backgroundColor = NSColor.elementBackground
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        window.identifier = .mainWindow
        window.minSize = CGSize(width: 1060, height: 700)

        window.isMovableByWindowBackground = true
        window.tabbingMode = .disallowed

        self.window = window

        if UserDefaults.standard.bool(forKey: "signup") == false {
            window.setFrame(MainWindowController.defaultRect, display: true)
        } else {
            window.setFrameUsingName("main")
        }
    }
}

private extension NSUserInterfaceItemIdentifier {
    static let mainWindow = NSUserInterfaceItemIdentifier(rawValue: "main")
}
