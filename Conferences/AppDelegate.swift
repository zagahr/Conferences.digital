//
//  AppDelegate.swift
//  Conferences
//
//  Created by Timon Blask on 30/01/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa
import Kingfisher
import TinyConstraints
import LetsMove

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let coordinator = AppCoordinator(windowController: MainWindowController())

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard PFMoveIsInProgress() == false else { return }



        coordinator.start()
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        #if !DEBUG
        PFMoveToApplicationsFolderIfNecessary()
        #endif
    }

    func applicationWillBecomeActive(_ notification: Notification) {
        guard PFMoveIsInProgress() == false else { return }

        if !NSApp.windows.contains(where: { $0.isVisible }) {
            coordinator.windowController.showWindow(self)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            coordinator.windowController.showWindow(sender)

            return true
        }

        return false
    }
}

