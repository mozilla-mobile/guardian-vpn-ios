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
@testable import Firefox_Private_Network_VPN

class MockConnectionRxValue: ConnectionRxValueObserving {
    
    var rxValue: UInt = 0
    
    var rx: Observable<UInt> {
        return .create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }
            observer.on(.next(self.rxValue))
            return Disposables.create { }
        }
    }
}
