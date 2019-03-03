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
    lazy var titleBarViewController = TitleBarViewController()
    lazy var mainSplitViewController = SplitViewController()

    lazy var welcomeView: WelcomeView = {
        let v = WelcomeView()

        return v
    }()

    override func loadView() {
        view = NSView()

        addChild(titleBarViewController)
        addChild(mainSplitViewController)

        view.addSubview(titleBarViewController.view)
        view.addSubview(mainSplitViewController.view)

        titleBarViewController.view.edgesToSuperview(excluding: .bottom)
        mainSplitViewController.view.edgesToSuperview(excluding: .top)
        mainSplitViewController.view.topToBottom(of: titleBarViewController.view)

        view.addSubview(loadingView)
        loadingView.edgesToSuperview()
    }

    func showWelcomeView() {
        view.addSubview(welcomeView)
        welcomeView.edgesToSuperview()
    }
}

