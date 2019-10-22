// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation

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
