//
//  PKCECodeGenerator
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

struct PKCECodeGenerator {
    static var generateCode: (codeChallenge: String, codeVerifier: String) {
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = base64UrlEncode(sha256(string: codeVerifier))
        return (codeChallenge, codeVerifier)
    }

    private static func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return base64UrlEncode(Data(buffer))
    }

    private static func base64UrlEncode(_ data: Data?) -> String {
        guard let data = data else { return "" }
        return data.base64EncodedString()
                   .replacingOccurrences(of: "+", with: "-")
                   .replacingOccurrences(of: "/", with: "_")
                   .replacingOccurrences(of: "=", with: "")
    }

    private static func sha256(string: String) -> Data? {
        guard let data = string.data(using: .utf8) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
}
