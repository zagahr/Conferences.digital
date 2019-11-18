//
//  NSColor+Extension.swift
//  Conferences
//
//  Created by Timon Blask on 04/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

@objc extension NSColor {

    static var paneBackground: NSColor {
        return NSColor(red: 0.16, green: 0.16, blue: 0.16, alpha:1.0)
    }

    static var windowBackground: NSColor {
        return NSColor(red: 0.11, green: 0.11, blue: 0.11, alpha:1.0)
    }


    static var primaryText: NSColor {
        return NSColor(calibratedWhite: 0.9, alpha: 1.0)
    }

    static var secondaryText: NSColor {
        return NSColor(calibratedWhite: 0.75, alpha: 1.0)
    }

    static var tertiaryText: NSColor {
        return NSColor(calibratedWhite: 0.55, alpha: 1.0)
    }

    static var panelBackground: NSColor {
        return NSColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
    }

    static var darkWindowBackground: NSColor {
        return NSColor(red:0.12, green:0.12, blue:0.12, alpha:1.0)
    }

    static var elementBackground: NSColor {
        return NSColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
    }

    static var inactiveButton: NSColor {
        return NSColor(red:0.09, green:0.09, blue:0.09, alpha:1.0)
    }

    static var activeButton: NSColor {
        return NSColor(red:0.11, green:0.11, blue:0.11, alpha:1.0)
    }

    static var prefsPrimaryText: NSColor {
        return NSColor(calibratedRed: 0.90, green: 0.90, blue: 0.90, alpha: 1.00)
    }

    static var prefsSecondaryText: NSColor {
        return NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.75, alpha: 1.00)
    }

    static var prefsTertiaryText: NSColor {
        return NSColor(calibratedRed: 0.49, green: 0.49, blue: 0.49, alpha: 1.00)
    }

    static var errorText: NSColor {
        return NSColor(calibratedRed: 0.85, green: 0.18, blue: 0.18, alpha: 1.00)
    }

    static var inactiveColor: NSColor {
        return NSColor.init(hexString: "B3B3B3")
    }

    static var activeColor: NSColor {
        return .white
    }

}
