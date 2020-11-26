//
//  main.swift
//  Conferences
//
//  Created by Timon Blask on 26/11/2020.
//  Copyright © 2020 Timon Blask. All rights reserved.
//

import Foundation

private func isTestRun() -> Bool {
    return NSClassFromString("XCTestCase") != nil
}

if isTestRun() {
    NSApplication.shared.run()
} else {
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
}
