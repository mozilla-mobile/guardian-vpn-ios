//
//  ConnectionHealthMonitor
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import RxSwift
import RxCocoa
import os.log

class ConnectionHealthMonitor: ConnectionHealthMonitoring {

    static let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    // TODO: DI here
    private let pinger: Pinging
    private let timerFactory: TimerFactory
    private let rxValueObserving: ConnectionRxValueObserving

    //swiftlint:disable:next implicitly_unwrapped_optional
    private var hostAddress: String!
    private var timer: Timer?

    private var _currentState = BehaviorRelay<ConnectionHealth>(value: .initial)
    var currentState: Observable<ConnectionHealth> {
        return _currentState.asObservable()
    }
    private var disposeBag = DisposeBag()

    init(pinger: Pinging = LongPinger(),
         timerFactory: TimerFactory = ConnectionTimerFactory(),
         rxValueObserving: ConnectionRxValueObserving = ConnectionRxValue()) {
        self.pinger = pinger
        self.timerFactory = timerFactory
        self.rxValueObserving = rxValueObserving
    }

    func start(hostAddress: String) {
        self.hostAddress = hostAddress

        configureLogging()
        startStateMachine()
        startPinging()
        observeRxValue()
    }

    private func configureLogging() {
        //swiftlint:disable:next trailing_closure
        _currentState
            .distinctUntilChanged()
            .withPrevious(startWith: _currentState.value)
            .subscribe(onNext: { prevState, currentState in
                  Logger.global?.log(message: "Connection health updated: \(prevState) -> \(currentState)")
            }).disposed(by: disposeBag)
    }

    private func startStateMachine() {
        if _currentState.value == .initial {
            move(to: .stable)
        }
    }

    private func observeRxValue() {
        //swiftlint:disable:next trailing_closure
        rxValueObserving
            .rx
            .withPrevious(startWith: nil)
            .subscribe(onNext: { [unowned self] previousRx, newRx in
                guard
                    let previousRx = previousRx,
                    let newRx = newRx
                else { return }

                if newRx > previousRx {
                    self.move(to: .stable)
                }
            }).disposed(by: disposeBag)
    }

    func stop() {
        pinger.stop()
        disposeBag = DisposeBag()

        timer?.invalidate()
        timer = nil
    }

    func reset() {
        stop()

        _currentState.accept(.initial)
    }

    private func move(to destinationState: ConnectionHealth) {
        let originalState = _currentState.value

        switch (originalState, destinationState) {
        case (_, .stable):
            _currentState.accept(.stable)
            startUnstableTimer()

        case (.stable, .unstable):
            _currentState.accept(.unstable)
            startNoSignalTimer()

        case (.unstable, .noSignal):
            _currentState.accept(.noSignal)

        default: break
        }
    }

    private func startPinging() {
        pinger.start(hostAddress: self.hostAddress)
    }

    private func startUnstableTimer() {
        timer?.invalidate()
        timer = timerFactory.unstableStateTimer { [unowned self] _ in
            self.move(to: .unstable)
        }
    }

    private func startNoSignalTimer() {
        timer?.invalidate()
        timer = timerFactory.noSignalStateTimer { _ in
            self.move(to: .noSignal)
        }
    }
}
