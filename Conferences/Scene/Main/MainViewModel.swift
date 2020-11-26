//
//  MainViewModel.swift
//  Conferences
//
//  Created by Timon Blask on 26/11/2020.
//  Copyright © 2020 Timon Blask. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MainViewModelFactory {

    func viewModel(
        viewDidLoad: Signal<Void>,
        retryTapped: Signal<Void>
    ) -> (
        talks: Driver<[Codable]>,
        isBusy: Driver<Bool>,
        showError: Driver<APIError>,
        trackEvent: Driver<Void>
    )

}

extension MainFactory: MainViewModelFactory {

    func viewModel(
        viewDidLoad: Signal<Void>,
        retryTapped: Signal<Void>
    ) -> (
        talks: Driver<[Codable]>,
        isBusy: Driver<Bool>,
        showError: Driver<APIError>,
        trackEvent: Driver<Void>
    ) {

        let isBusy = PublishRelay<Bool>()

        let fetchTalksState = Observable
            .merge(
                viewDidLoad.asObservable(),
                retryTapped.asObservable()
            )
            .do(onNext: { isBusy.accept(true) })
            .flatMap {
                self.talkService
                    .fetchData()
                    .asObservable()
                    .do(onNext: { _ in isBusy.accept(false) })
                    .do(onError: { _ in isBusy.accept(false) })
                    .materialize()
                    .share(replay: 1)
            }
            .share(replay: 1)

        let showError = fetchTalksState
            .compactMap { $0.error as? APIError }
            .asDriver(onErrorDriveWith: .never())

        let fetchTalksSuccess = fetchTalksState
            .compactMap { $0.element }

        let talks = fetchTalksSuccess
            .asDriver(onErrorDriveWith: .never())

        let trackEvent = fetchTalksSuccess
            .filter { _ in self.isNewUser }
            .map { _ in }
            .do(onNext: self.setNewUser)
            .asDriver(onErrorDriveWith: .never())

        return (
            talks: talks,
            isBusy: isBusy.asDriver(onErrorDriveWith: .never()),
            showError: showError,
            trackEvent: trackEvent
        )
    }

}
