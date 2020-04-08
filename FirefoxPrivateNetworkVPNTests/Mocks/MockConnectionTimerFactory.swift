//
//  MockConnectionTimerFactory
//  FirefoxPrivateNetworkVPNTests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
@testable import Firefox_Private_Network_VPN

class MockConnectionTimerFactory: TimerFactory {

    private var unstableTimerExpirationCount: Int
    private var noSignalTimerExpirationCount: Int

    /**
     - parameter unstableTimerExpirationCount: number of expirations to take place for unstable timer
     - parameter noSignalTimerExpirationCount: number of expirations to take place for no-signal timer
     */
    init(unstableTimerExpirationCount: Int, noSignalTimerExpirationCount: Int) {
        self.unstableTimerExpirationCount = unstableTimerExpirationCount
        self.noSignalTimerExpirationCount = noSignalTimerExpirationCount
    }

    func unstableStateTimer(block: @escaping (Timer) -> Void) -> Timer {
        let timer = Timer.init()
        if unstableTimerExpirationCount > 0 {
            block(timer)
            unstableTimerExpirationCount -= 1
        }

        return timer
    }

    func noSignalStateTimer(block: @escaping (Timer) -> Void) -> Timer {
        let timer = Timer.init()
        if noSignalTimerExpirationCount > 0 {
            block(timer)
            noSignalTimerExpirationCount -= 1
        }

        return timer

    }
}
