//
//  VerifyResponse
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
