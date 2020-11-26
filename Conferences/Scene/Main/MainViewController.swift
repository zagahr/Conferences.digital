//
//  MainSplitViewController.swift
//  Conferences
//
//  Created by Timon Blask on 12/02/19.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

final class MainViewController: NSSplitViewController {
    
    // MARK: - Properties

    typealias Factory = MainViewModelFactory
    
    private let factory: Factory
    private let bag = DisposeBag()
    
    weak var coordinateDelegate: MainCoordinator?

    lazy var listViewController: ListViewController = {
        let vc = ListViewController()
        vc.tableView.delegate = self.coordinateDelegate?.listDataDelegate
        vc.tableView.dataSource = self.coordinateDelegate?.listDataDelegate

        return vc
    }()

    lazy var detailViewController: DetailSplitViewController = {
        let vc = DetailSplitViewController()
        vc.shelfController.delegate = self.coordinateDelegate

        return vc
    }()
    
    private lazy var loadingView = LoadingView()

    private var listItem: NSSplitViewItem?
    
    // MARK: - Initialization
    
    init(factory: Factory) {
        self.factory = factory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let width = listItem?.viewController.view.frame.width, width == 320 {
            splitView.setPosition(480, ofDividerAt: 0)
        }
    }
    
    // MARK: - Private Methods
    
    private func configureView() {
        view.wantsLayer = false
        listItem = NSSplitViewItem(sidebarWithViewController: listViewController)
        listItem?.canCollapse = true

        let detailItem = NSSplitViewItem(viewController: detailViewController)

        addSplitViewItem(listItem!)
        addSplitViewItem(detailItem)
        
        listViewController.view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        detailViewController.view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        detailViewController.view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        splitView.setValue(NSColor.listBackground, forKey: "dividerColor")
        splitView.dividerStyle = .thick
        splitView.autosaveName = "SplitView"
        
        view.addSubview(loadingView)
        loadingView.edgesToSuperview()
    }
    
    private func bind() {
        let (talks, isBusy, showError, trackEvent) = factory.viewModel(
            viewDidLoad: .just(()),
            retryTapped: loadingView.reloadButton.rx.tap.asSignal()
        )

        bag.insert(
            talks.drive(onNext: { [unowned self] talks in
                self.coordinateDelegate?.listDataDelegate.talks = talks
                self.listViewController.tableView.reloadData()
            }),
            isBusy.drive(onNext: { [unowned self] isBusy in
                if isBusy {
                    self.loadingView.show()
                } else {
                    self.loadingView.hide()
                }
            }),
            showError.drive(onNext: { [unowned self] error in
                self.loadingView.show(error)
            }),
            trackEvent.drive(onNext: { _ in
                LoggingHelper.registerSignUp()
            })
        )
    }
}

