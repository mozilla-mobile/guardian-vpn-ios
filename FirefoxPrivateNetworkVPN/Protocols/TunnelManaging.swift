//
//  TunnelManaging
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
import RxRelay

protocol TunnelManaging {
    var cityChangedEvent: PublishSubject<VPNCity> { get }
    var stateEvent: BehaviorRelay<VPNState> { get }
    var timeSinceConnected: Double { get }

    func connect(with device: Device?) -> Single<Void>
    func switchServer(with device: Device) -> Single<Void>
    func stop()
    func getReceivedBytes(completionHandler: @escaping ((UInt?) -> Void))
}
