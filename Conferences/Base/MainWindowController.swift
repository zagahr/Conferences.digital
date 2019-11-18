//
//  MainWindowController.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class MainWindowController: NSWindowController {
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

        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .dark
        window.contentView = visualEffect

        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)

        window.identifier = .mainWindow
        window.minSize = CGSize(width: 530, height: 350)

        //window.isMovableByWindowBackground = true
        //window.tabbingMode = .disallowed

        self.window = window

        if UserDefaults.standard.bool(forKey: "initialSize") == false {
            UserDefaults.standard.setValue(true, forKey: "initialSize")
            window.setFrame(MainWindowController.defaultRect, display: true)
            window.saveFrame(usingName: .init("main"))
        } else {
            window.setFrameUsingName("main")
        }
    }
}

private extension NSUserInterfaceItemIdentifier {
    static let mainWindow = NSUserInterfaceItemIdentifier(rawValue: "main")
}
