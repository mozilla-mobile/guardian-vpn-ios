//
//  MockConnectionTimeFactory
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

class MockConnectionTimeFactory: TimerFactory {
    
    var unstableWaitTime: TimeInterval = 5
    var noSignalWaitTime: TimeInterval = 30
    
    func unstableStateTimer(block: @escaping (Timer) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: unstableWaitTime, repeats: false, block: block)
    }
    
    func noSignalStateTimer(block: @escaping (Timer) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: noSignalWaitTime, repeats: false, block: block)
    }
}
