//
//  ConnectionTimerFactory
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

protocol TimerFactory {
    func unstableStateTimer(block: @escaping (Timer) -> Void) -> Timer
    func noSignalStateTimer(block: @escaping (Timer) -> Void) -> Timer
}

struct ConnectionTimerConfig {
    let unstableWaitTime: TimeInterval = 5
    let noSignalWaitTime: TimeInterval = 30
}

class ConnectionTimerFactory: TimerFactory {

    private let config: ConnectionTimerConfig

    init(config: ConnectionTimerConfig = ConnectionTimerConfig()) {
        self.config = config
    }

    func unstableStateTimer(block: @escaping (Timer) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: config.unstableWaitTime, repeats: false, block: block)
    }

    func noSignalStateTimer(block: @escaping (Timer) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: config.noSignalWaitTime, repeats: false, block: block)
    }
}
