//
//  HeartbeatMonitoring
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

extension Notification.Name {
    static let expiredSubscriptionNotification = Notification.Name("expiredSubscription")
    static let activeSubscriptionNotification = Notification.Name("activeSubscription")
}

protocol HeartbeatMonitoring {
    func start()
    func stop()
    func pollNow()
}
