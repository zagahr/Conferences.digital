//
//  AppCoordinator.swift
//  Conferencess
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa
import FirebaseCore
import Fabric
import Crashlytics

final class AppCoordinator {
    var windowController: MainWindowController
    var mainCoordinator: MainCoordinator

    init(windowController: MainWindowController) {
        mainCoordinator = MainCoordinator()

        self.windowController = windowController
        FirebaseApp.configure()

        #if !DEBUG
            UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
            Fabric.with([Crashlytics.self])
        #endif

        _ = NotificationCenter.default.addObserver(forName: NSApplication.didFinishLaunchingNotification, object: nil, queue: nil) { _ in self.startup() }

        if #available(macOS 10.14, *)  {
            NSApp.appearance = NSAppearance.init(named: .darkAqua)
        }
    }

    private func startup() {
        windowController.contentViewController = mainCoordinator.rootViewController
        windowController.showWindow(self)
        windowController.windowFrameAutosaveName = "main"
    }
}
