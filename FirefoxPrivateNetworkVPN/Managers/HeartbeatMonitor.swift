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

    private static let timeInterval: TimeInterval = 3600
    private var timer: DispatchSourceTimer?
    private var accountManager: AccountManaging { return DependencyManager.shared.accountManager }

    /**
     Starts the heart beat and polls the service end points for data immediately.
     */
    func start() {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: .seconds(3600), leeway: .seconds(1))
        timer?.setEventHandler { [weak self] in
            self?.pollUser()
            self?.pollVPNServers()
        }
        timer?.activate()
    }

    func stop() {
        timer = nil
    }

    func pollNow() {
        stop()
        start()
    }

    private func pollUser() {
        accountManager.getUser { result in
            switch result {
            case .success:
                guard let account = self.accountManager.account else { return }
                let name: NSNotification.Name = account.isSubscriptionActive ? .activeSubscriptionNotification : .expiredSubscriptionNotification
                NotificationCenter.default.post(name: name, object: nil)
            case .failure(let error):
                if error == .subscriptionError {
                    NotificationCenter.default.post(name: .expiredSubscriptionNotification, object: nil)
                }
            }
        }
    }

    private func pollVPNServers() {
        guard let account = accountManager.account else { return }

        accountManager.retrieveVPNServers(with: account.token) { _ in }
    }
}
