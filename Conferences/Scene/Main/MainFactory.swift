//
//  MainFactory.swift
//  Conferences
//
//  Created by Timon Blask on 26/11/2020.
//  Copyright © 2020 Timon Blask. All rights reserved.
//

import Foundation

final class MainFactory {
    
    // MARK: - Properties
    
    let talkService: TalkServiceType
    let isNewUser: Bool
    let setNewUser: () -> ()
    
    // MARK: - Initialization
    
    init(
        talkService: TalkServiceType,
        isNewUser: Bool,
        setNewUser: @escaping () -> ()
    ) {
        self.talkService = talkService
        self.isNewUser = isNewUser
        self.setNewUser = setNewUser
    }
    
}
