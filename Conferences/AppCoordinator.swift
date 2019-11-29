//
//  AppCoordinator.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class AppCoordinator {
    var windowController: MainWindowController
    private var mainCoordinator: MainCoordinator

    init(windowController: MainWindowController) {
        mainCoordinator = MainCoordinator()

        self.windowController = windowController
        NSApp.appearance = NSAppearance(named: .darkAqua)
    }

    func start() {
        #if DEBUG
            do {
                _ = try PathUtil.appSupportPathCreatingIfNeeded()
            } catch {
                fatalError(error.localizedDescription)
            }            
        #else
            UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
            LoggingHelper.install()
        #endif

        mainCoordinator.start()

        windowController.contentViewController = mainCoordinator.rootViewController
        windowController.showWindow(self)
        windowController.windowFrameAutosaveName = "main"
    }
}
