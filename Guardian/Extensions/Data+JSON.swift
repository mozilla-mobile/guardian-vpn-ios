// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation

extension Data {
    func convert<T>(to type: T.Type) throws -> T where T: Decodable { //overrides error thrown
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(type, from: self)
            return decodedResponse
        } catch {
            throw GuardianFailReason.couldNotDecodeFromJson
        }
    }
}
