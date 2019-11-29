//
//  ConnectionHealthMonitorSpec
//  FirefoxPrivateNetworkVPNTests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import Quick
import Nimble
import RxSwift
import RxCocoa
import RxTest
@testable import Firefox_Private_Network_VPN

//swiftlint:disable implicitly_unwrapped_optional
class ConnectionHealthMonitorSpec: QuickSpec {

    private static let hostAddress = "testHost"

    override func spec() {
        describe("ConnectionHealthMonitor") {

            var sut: ConnectionHealthMonitor!
            var pinger: MockLongPinger!
            var timerFactory: MockConnectionTimerFactory!
            var rxValueObserving: MockConnectionRxValue!

            beforeEach {
                pinger = MockLongPinger()
                rxValueObserving = MockConnectionRxValue()
            }

            context("after being instatiated") {
                it("should be in an initial state") {
                    timerFactory = MockConnectionTimerFactory(unstableTimerExpirationCount: 0, noSignalTimerExpirationCount: 0)
                    sut = ConnectionHealthMonitor(pinger: pinger, timerFactory: timerFactory, rxValueObserving: rxValueObserving)

                    expect(state(of: sut)).to(equal(ConnectionState.initial))
                }
            }

            context("when started") {
                it("should be in a stable state") {
                    // Both times do no expire, resulting the connection state to be stable
                    timerFactory = MockConnectionTimerFactory(unstableTimerExpirationCount: 0, noSignalTimerExpirationCount: 0)
                    sut = ConnectionHealthMonitor(pinger: pinger, timerFactory: timerFactory, rxValueObserving: rxValueObserving)
                    sut.start(hostAddress: ConnectionHealthMonitorSpec.hostAddress)

                    expect(state(of: sut)).to(equal(ConnectionState.stable))
                }
            }

            context("after unstable timer expires") {
                it("should be in an unstable state") {
                    // Unstable timer expires once, resulting in the unstable state
                    timerFactory = MockConnectionTimerFactory(unstableTimerExpirationCount: 1, noSignalTimerExpirationCount: 0)
                    sut = ConnectionHealthMonitor(pinger: pinger, timerFactory: timerFactory, rxValueObserving: rxValueObserving)
                    sut.start(hostAddress: ConnectionHealthMonitorSpec.hostAddress)

                    expect(state(of: sut)).to(equal(ConnectionState.unstable))
                }
            }

            context("after unstable and no signal timers expire") {
                it("should be in a no signal state") {
                    // Both times expire once each, resulting the connection state to be no signal
                    timerFactory = MockConnectionTimerFactory(unstableTimerExpirationCount: 1, noSignalTimerExpirationCount: 1)
                    sut = ConnectionHealthMonitor(pinger: pinger, timerFactory: timerFactory, rxValueObserving: rxValueObserving)
                    sut.start(hostAddress: ConnectionHealthMonitorSpec.hostAddress)

                    expect(state(of: sut)).to(equal(ConnectionState.noSignal))
                }
            }

            context("in a unstable state, and Rx bytes count increased") {
                it("should turn into a stable state") {
                    // Unstable timer expires once, resulting in the unstable state to begin with
                    timerFactory = MockConnectionTimerFactory(unstableTimerExpirationCount: 1, noSignalTimerExpirationCount: 0)
                    sut = ConnectionHealthMonitor(pinger: pinger, timerFactory: timerFactory, rxValueObserving: rxValueObserving)
                    sut.start(hostAddress: ConnectionHealthMonitorSpec.hostAddress)

                    rxValueObserving.rxRelay.accept(1)
                    rxValueObserving.rxRelay.accept(10)

                    expect(state(of: sut)).to(equal(ConnectionState.stable))
                }
            }

            context("in a no signal state, and Rx bytes count increased") {
                it("should turn into a stable state") {
                    // Both times expire once each, resulting the connection state to be no signal to begin with
                    timerFactory = MockConnectionTimerFactory(unstableTimerExpirationCount: 1, noSignalTimerExpirationCount: 1)
                    sut = ConnectionHealthMonitor(pinger: pinger, timerFactory: timerFactory, rxValueObserving: rxValueObserving)
                    sut.start(hostAddress: ConnectionHealthMonitorSpec.hostAddress)

                    rxValueObserving.rxRelay.accept(1)
                    rxValueObserving.rxRelay.accept(10)

                    expect(state(of: sut)).to(equal(ConnectionState.stable))
                }
            }
        }
    }
}

private func state(of sut: ConnectionHealthMonitor) -> ConnectionState? {
    let testScheduler = TestScheduler(initialClock: 0)
    let disposeBag = DisposeBag()
    let observer = testScheduler.createObserver(ConnectionState.self)
    sut.currentState.drive(observer).disposed(by: disposeBag)
    testScheduler.start()

    return observer.events.last?.value.element
}
