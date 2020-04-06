//
//  TunnelManagerUtilities
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import RxSwift
import RxRelay

class TunnelManagerUtilities {

    /// This adds artificial delays for the VPN state transitions.
    ///
    /// - Parameters:
    ///   - vpnStateSubject: the raw VPN state events
    ///   - processedStateEvent: the processed VPN state events with the delays
    ///   - disposeBag: Rx dispose bag
    static func observe(_ rawStateSubject: BehaviorRelay<VPNState>,
                        bindTo processedStateSubject: BehaviorRelay<VPNState>,
                        disposedBy disposeBag: DisposeBag) {
        rawStateSubject
            .withPrevious()
            .map { states -> (VPNState, VPNState) in
                let previousState = states[0]
                let currentState = states[1]
                return (previousState, currentState)
            }
            .filter { previous, current in
                return previous != current
            }.flatMapLatest { previous, current -> Observable<VPNState> in
                switch (previous, current) {
                case (.connecting, .on), (.disconnecting, .off):
                    return Observable.just(current).delay(DispatchTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
                case (.switching, .on):
                    return Observable.just(current).delay(DispatchTimeInterval.milliseconds(2000), scheduler: MainScheduler.instance)
                case (.off, .disconnecting):
                    return Observable.just(.error(.couldNotConnect))
                default: return Observable.just(current)
                }
            }.bind(to: processedStateSubject)
            .disposed(by: disposeBag)
    }
}
