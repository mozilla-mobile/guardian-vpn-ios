//
//  Data+JSON
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
    func unwrap() -> Result<Data, Error> {
        if case .success(let optionalValue) = self, let value = optionalValue {
            return .success(value)
        }
        return .failure(GuardianFailReason.missingData)
    }
}

extension Data {
    func convert<T>(to type: T.Type) -> Result<T, Error> where T: Decodable { //overrides error thrown
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(type, from: self)
            return .success(decodedResponse)
        } catch {
            return .failure(GuardianFailReason.couldNotDecodeFromJson)
        }
    }
}
