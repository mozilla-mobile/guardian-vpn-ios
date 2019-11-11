//
//  VerifyResponse
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

struct VerifyResponse: Codable {
    let user: User
    let token: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(user, forKey: .user)
        try container.encode(token, forKey: .token)
    }

    enum CodingKeys: String, CodingKey {
        case user
        case token
    }
}
