//
//  HeartbeatMonitor
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import RxSwift
import RxCocoa

class HeartbeatMonitor: HeartbeatMonitoring {
    static let sharedManager = HeartbeatMonitor()

    private static let timeInterval: TimeInterval = 3600
    private var timer: DispatchSourceTimer?
    private var _subscriptionExpiredEvent = PublishSubject<Void>()

    var subscriptionExpiredEvent: Observable<Void> {
        return _subscriptionExpiredEvent.asObservable()
    }

    func start() {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: .seconds(3600), leeway: .seconds(1))
        timer?.setEventHandler { [weak self] in
            self?.poll()
        }
        timer?.activate()
    }

    func stop() {
        timer = nil
    }

    private func poll() {
        guard let account = DependencyFactory.sharedFactory.accountManager.account else { return }
        account.getUser { result in
            guard case .failure(let error) = result,
                let subscriptionError = error as? GuardianAPIError,
                subscriptionError.isAuthError else { return }

            self._subscriptionExpiredEvent.onNext(())
        }
    }
}
