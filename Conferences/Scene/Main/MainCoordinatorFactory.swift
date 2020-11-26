//
//  MainCoordinatorFactory.swift
//  Conferences
//
//  Created by Timon Blask on 26/11/2020.
//  Copyright © 2020 Timon Blask. All rights reserved.
//

import Foundation

protocol MainCoordinatorFactory {
    func mainCoordinator() -> MainCoordinator
}

extension MainFactory: MainCoordinatorFactory {
    
    func mainCoordinator() -> MainCoordinator {

        let viewController = MainViewController(
            factory: self
        )
        
        return MainCoordinator(
            rootViewController: viewController
        )
    }
    
} 
