// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

public enum NetworkingFailReason: String, Error {
    case no200 = "Response status code not 200"
    case couldNotDecodeFromJson = "Could not decode from JSON"
}

enum HTTPMethod: String {
    case GET
    case POST
}

enum GuardianRelativeRequest {
    case login
    case verify(String)
    case retrieveServers

    var endpoint: String {
        switch self {
        case .login:
            return "/api/v1/vpn/login/"
        case .verify(let token):
            return "/api/v1/vpn/login/verify/" + token
        case .retrieveServers:
            return "/api/v1/vpn/servers/"

        }
    }
}
