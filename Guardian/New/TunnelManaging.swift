//
//  TunnelManaging
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

protocol TunnelManaging {
    var cityChangedEvent: PublishSubject<VPNCity> { get }
    var stateEvent: BehaviorRelay<VPNState> { get }
    var timeSinceConnected: Double { get }

    func connect(with device: Device?)
    func stop()
    func switchServer(with device: Device)
}
