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
    func decode<T>(to type: T.Type) -> Result<T, Error> where T: Decodable {
        if case .failure(let error) = self {
            return .failure(error)
        }
        guard case .success(let optionalData) = self, let data = optionalData else {
            return .failure(GuardianAppError.missingData)
        }
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(type, from: data)
            return .success(decodedResponse)
        } catch {
            return .failure(GuardianAppError.couldNotDecodeFromJson)
        }
    }
}
