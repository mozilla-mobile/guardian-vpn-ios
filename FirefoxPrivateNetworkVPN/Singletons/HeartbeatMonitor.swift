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

class HeartbeatMonitor: HeartbeatMonitoring {
    static let sharedManager = HeartbeatMonitor()

    private static let timeInterval: TimeInterval = 3600
    private var timer: DispatchSourceTimer?

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

    //poll now and restart the timer
    func pollNow() {
        stop()
        start()
    }

    private func poll() {
        guard let account = DependencyFactory.sharedFactory.accountManager.account,
            account.hasDeviceBeenAdded else { return }

        account.getUser { result in
            if case .success = result {
                NotificationCenter.default.post(name: NSNotification.Name.activeSubscriptionNotification, object: nil)
            }
            guard case .failure(let error) = result,
                let subscriptionError = error as? GuardianAPIError,
                subscriptionError.isAuthError else { return }

            NotificationCenter.default.post(name: NSNotification.Name.expiredSubscriptionNotification, object: nil)
        }
    }
}
