// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

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
