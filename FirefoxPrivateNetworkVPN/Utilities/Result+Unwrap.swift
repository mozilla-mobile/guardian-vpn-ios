//
//  Result+Unwrap
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

extension Result where Success == Data? {
    func unwrapSuccess() -> Result<Data, Error> {
        if case .success(let optionalValue) = self, let value = optionalValue {
            return .success(value)
        }
        return .failure(GuardianFailReason.missingData)
    }
}
