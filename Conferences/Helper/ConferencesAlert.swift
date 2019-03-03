//
//  ConferencesAlert.swift
//  Conferences
//
//  Created by Timon Blask on 09/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class ConferencesAlert {

    static func show(with error: Error) {
        DispatchQueue.main.async {
            let alert = NSAlert(error: error)

            if let apiError = error as? APIError {
                alert.messageText = "Error"
                alert.informativeText  = apiError.message
            } else if let playbackError = error as? ConferencesError {
                alert.messageText = "Playback Error"
                alert.informativeText  = playbackError.message
            }

            alert.runModal()
        }
    }
}
