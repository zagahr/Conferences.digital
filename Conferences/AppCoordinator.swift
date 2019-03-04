//
//  AppCoordinator.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

final class AppCoordinator {
    var windowController: MainWindowController
    var mainCoordinator: MainCoordinator

    init(windowController: MainWindowController) {
        mainCoordinator = MainCoordinator()

        self.windowController = windowController

        #if !DEBUG
            UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
            Fabric.with([Crashlytics.self])
        #endif

        if #available(macOS 10.14, *)  {
            NSApp.appearance = NSAppearance.init(named: .darkAqua)
        }
    }

    func start() {
        mainCoordinator.start()

        windowController.contentViewController = mainCoordinator.rootViewController
        windowController.showWindow(self)
        windowController.windowFrameAutosaveName = "main"
    }
}
