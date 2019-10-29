// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation

struct LoginCheckpointModel: Decodable {
    let loginUrl: URL
    let verificationUrl: URL
    let expiresOn: Date
    let pollInterval: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let loginUrlString = try container.decode(String.self, forKey: .loginUrl)
        loginUrl = URL(string: loginUrlString)!

        let verificationUrlString = try container.decode(String.self, forKey: .verificationUrl)
        verificationUrl = URL(string: verificationUrlString)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let dateString = try container.decode(String.self, forKey: .expiresOn)
        expiresOn = dateFormatter.date(from: dateString)!

        pollInterval = try container.decode(Int.self, forKey: .pollInterval)
    }

    enum CodingKeys: String, CodingKey {
        case loginUrl = "login_url"
        case verificationUrl = "verification_url"
        case expiresOn = "expires_on"
        case pollInterval = "poll_interval"
    }
}
