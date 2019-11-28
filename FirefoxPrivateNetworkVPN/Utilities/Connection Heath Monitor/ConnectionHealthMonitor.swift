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

enum ConnectionState {
    case initial, stable, unstable, noSignal
}

class ConnectionHealthMonitor {

    // TODO: DI here
    private let pinger: Pinging
    private let timerFactory: TimerFactory
    private let rxValueObserving: ConnectionRxValueObserving

    //swiftlint:disable:next implicitly_unwrapped_optional
    private var hostAddress: String!
    private var timer: Timer?

    private var _currentState = BehaviorRelay<ConnectionState>(value: .initial)
    var currentState: Driver<ConnectionState> {
        return _currentState.asDriver(onErrorJustReturn: .noSignal)
    }
    private var disposeBag = DisposeBag()

    init(pinger: Pinging, timerFactory: TimerFactory, rxValueObserving: ConnectionRxValueObserving) {
        self.pinger = pinger
        self.timerFactory = timerFactory
        self.rxValueObserving = rxValueObserving
    }

    func start(hostAddress: String) {
        self.hostAddress = hostAddress

        if _currentState.value == .initial {
            move(to: .stable)
        }

        startPinging()
        timer = timerFactory.unstableStateTimer { [unowned self] _ in
            self.move(to: .unstable)
        }
        rxValueObserving
            .rx
            .withPrevious(startWith: 0)
            .subscribe(onNext: { [unowned self] previousRx, newRx in
                if newRx > previousRx {
                    self.move(to: .stable)
                }
            }).disposed(by: disposeBag)
    }

    func stop() {
        _currentState.accept(.initial)

        pinger.stop()
        disposeBag = DisposeBag()

        timer?.invalidate()
        timer = nil
    }

    private func move(to destinationState: ConnectionState) {
        switch (_currentState.value, destinationState) {
        case (.initial, .stable): break
        case (.stable, .stable): break
        case (.stable, .unstable): break
        case (.unstable, .noSignal): break
        case (.unstable, .stable): break
        case (.noSignal, .stable): break

        default: break
        }
    }

    private func startPinging() {
        pinger.start(hostAddress: self.hostAddress)
    }
}
