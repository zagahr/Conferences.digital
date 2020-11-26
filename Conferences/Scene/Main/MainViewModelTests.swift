//
//  MainViewModelTests.swift
//  Conferences
//
//  Created by Timon Blask on 26/11/2020.
//  Copyright © 2020 Timon Blask. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

@testable import Conferences

final class MainViewModelTests: XCTestCase {

    // MARK: - Types

    final class MockTalkService: TalkServiceType {

        struct Mocks {
            var result: Observable<[Codable]> = .just([])
        }

        var mocks = Mocks()

        func fetchData() -> Observable<[Codable]> {
            mocks.result
        }

    }

    // MARK: - Properties

    private var bag: DisposeBag!
    private var scheduler: TestScheduler!
    private var talkService: MockTalkService!
    private var factory: MainFactory!

    private var viewDidLoad: PublishRelay<Void>!
    private var retryTapped: PublishRelay<Void>!

    private var talks: Driver<[Codable]>!
    private var isBusy: Driver<Bool>!
    private var showError: Driver<APIError>!
    private var trackEvent: Driver<Void>!

    // MARK: -  XCTestCase

    override func setUp() {
        super.setUp()

        bag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        talkService = MockTalkService()

        viewDidLoad = .init()
        retryTapped = .init()

        makeSubject()
    }

    override func tearDown() {
        bag = nil
        scheduler = nil
        talkService = nil
        viewDidLoad = nil
        retryTapped = nil
        talks = nil
        isBusy = nil
        showError = nil
        trackEvent = nil

        super.tearDown()
    }

    // MARK: - Tests

    func testTalks_fetchSuccessful_emitsValue() {
        let spy = scheduler.createObserver(Bool.self)

        talks.map { _ in true }.drive(spy).disposed(by: bag)

        scheduler.scheduleAt(100) {
            self.viewDidLoad.accept(())
        }
        scheduler.start()

        XCTAssertEqual(spy.events, [.next(100, true)])
    }

    func testTalks_fetchFailed_wontEmitValue() {
        let spy = scheduler.createObserver(Bool.self)

        talkService.mocks.result = .error(APIError.unknown)
        talks.map { _ in true }.drive(spy).disposed(by: bag)

        scheduler.scheduleAt(100) {
            self.viewDidLoad.accept(())
        }
        scheduler.start()

        XCTAssertEqual(spy.events, [])
    }

    func testTalks_retryTapped_fetchSuccessful_emitsValue() {
        let spy = scheduler.createObserver(Bool.self)

        talks.map { _ in true }.drive(spy).disposed(by: bag)

        scheduler.scheduleAt(100) {
            self.retryTapped.accept(())
        }
        scheduler.start()

        XCTAssertEqual(spy.events, [.next(100, true)])
    }

    func testTalks_fetchFailed_retryTapped_fetchSuccessfull_emitsValue() {
        let spy = scheduler.createObserver(Bool.self)

        talkService.mocks.result = .error(APIError.unknown)
        talks.map { _ in true }.drive(spy).disposed(by: bag)

        scheduler.scheduleAt(100) {
            self.viewDidLoad.accept(())
        }

        scheduler.scheduleAt(200) {
            self.talkService.mocks.result = .just([])
            self.retryTapped.accept(())
        }
        scheduler.start()

        XCTAssertEqual(spy.events, [.next(200, true)])
    }

    func testIsBusy_fetchFailed_retryTapped_fetchSuccessfull_emitsValue() {
        let spy = scheduler.createObserver(Bool.self)
        let fakeSpy = scheduler.createObserver(Bool.self)

        talkService.mocks.result = .error(APIError.unknown)
        isBusy.drive(spy).disposed(by: bag)
        talks.map { _ in false }.drive(fakeSpy).disposed(by: bag)

        scheduler.scheduleAt(100) {
            self.viewDidLoad.accept(())
        }

        scheduler.scheduleAt(200) {
            self.talkService.mocks.result = .just([])
            self.retryTapped.accept(())
        }
        scheduler.start()

        XCTAssertEqual(
            spy.events,
            [
                .next(100, true),
                .next(100, false),
                .next(200, true),
                .next(200, false)
            ]
        )
    }

    func testShowError_fetchTalksFailed_emitsValue() {
        let spy = scheduler.createObserver(Bool.self)

        talkService.mocks.result = .error(APIError.unknown)
        showError.map { _ in true }.drive(spy).disposed(by: bag)

        scheduler.scheduleAt(100) {
            self.viewDidLoad.accept(())
        }
        scheduler.start()

        XCTAssertEqual(spy.events, [.next(100, true)])
    }

    func testTrackEvent_isNewUser_emitsEvent() {
        makeSubject(isNewUser: true)
        let spy = scheduler.createObserver(Bool.self)

        scheduler.scheduleAt(100) {
            self.viewDidLoad.accept(())
        }
        trackEvent.map { _ in true }.drive(spy).disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(spy.events, [.next(100, true)])
    }

    func testTrackEvent_existingUser_wontEmitEvent() {
        let spy = scheduler.createObserver(Bool.self)

        scheduler.scheduleAt(100) {
            self.viewDidLoad.accept(())
        }
        trackEvent.map { _ in true }.drive(spy).disposed(by: bag)

        scheduler.start()

        XCTAssertEqual(spy.events, [])
    }

    func testTrackEvent_isNewUser_updatesUserDefaults() {
        let spy = scheduler.createObserver(Bool.self)
        let expectation = self.expectation(description: "User defaults updated")

        makeSubject(isNewUser: true) {
            expectation.fulfill()
        }

        scheduler.scheduleAt(100) {
            self.viewDidLoad.accept(())
        }
        trackEvent.map { _ in true }.drive(spy).disposed(by: bag)

        scheduler.start()

        waitForExpectations(timeout: 1.0, handler: nil)
    }


    // MARK: - Private Methods

    private func makeSubject(
        isNewUser: Bool = false,
        setNewUser: @escaping () -> () = {}
    ) {

        factory = MainFactory(
            talkService: talkService,
            isNewUser: isNewUser,
            setNewUser: setNewUser
        )

        let (talks, isBusy, showError, trackEvent) = factory.viewModel(
            viewDidLoad: viewDidLoad.asSignal(),
            retryTapped: retryTapped.asSignal()
        )

        self.talks = talks
        self.isBusy = isBusy
        self.showError = showError
        self.trackEvent = trackEvent
    }
}

