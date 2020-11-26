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

    init(
        mainCoordinator: MainCoordinator,
        windowController: MainWindowController
    ) {
        self.mainCoordinator = mainCoordinator
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

        windowController.contentViewController = mainCoordinator.start()
        windowController.showWindow(self)
        windowController.windowFrameAutosaveName = "main"
    }
}
