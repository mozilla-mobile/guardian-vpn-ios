//
//  GuardianAPIDateFormatter
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

class GuardianAPIDateFormatter: DateFormatter {
    override init() {
        super.init()
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.locale = Locale(identifier: "en_US_POSIX")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
