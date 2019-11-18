//
//  MainViewController.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa

final class MainViewController: NSViewController {

    lazy var loadingView = LoadingView()
    lazy var mainSplitViewController = SplitViewController()

    override func loadView() {
        view = NSView()
        addChild(mainSplitViewController)

        view.addSubview(mainSplitViewController.view)
        mainSplitViewController.view.edgesToSuperview()

        view.addSubview(loadingView)
        loadingView.edgesToSuperview()
    }

}

