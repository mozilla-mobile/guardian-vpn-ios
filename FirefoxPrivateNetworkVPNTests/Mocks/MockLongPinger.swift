//
//  MockLongPinger
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
@testable import Mozilla_VPN

class MockLongPinger: Pinging {

    func start(hostAddress: String) {
        /* Do nothing */
    }

    func stop() {
        /* Do nothing */
    }
}
