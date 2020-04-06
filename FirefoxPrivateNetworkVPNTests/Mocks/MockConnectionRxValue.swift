//
//  MockConnectionRxValue
//  FirefoxPrivateNetworkVPNTests
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
@testable import Firefox_Private_Network_VPN

class MockConnectionRxValue: ConnectionRxValueObserving {

    var rxRelay = BehaviorRelay<UInt>(value: 0)
    var rx: Observable<UInt> {
        return rxRelay.asObservable()
    }
}
