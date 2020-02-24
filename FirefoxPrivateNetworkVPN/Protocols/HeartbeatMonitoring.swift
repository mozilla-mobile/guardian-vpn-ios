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

import UIKit

extension Notification.Name {
    static let inactiveSubscriptionNotification = Notification.Name("inactiveSubscription")
}

protocol HeartbeatMonitoring {

    func start()
    func stop()
}
