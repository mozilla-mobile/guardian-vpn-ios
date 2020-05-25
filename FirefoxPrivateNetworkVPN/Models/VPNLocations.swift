//
//  VPNLocations
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

struct VPNCountry: Codable {
    let name: String
    let code: String
    var cities: [VPNCity]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        code = try container.decode(String.self, forKey: .code)
        cities = try container.decode([VPNCity].self, forKey: .cities)

        //sets the flagCode as the VPNCountry code
        cities = cities.map {
            return VPNCity(name: $0.name,
                           code: $0.code,
                           latitude: $0.latitude,
                           longitude: $0.longitude,
                           servers: $0.servers,
                           flagCode: code)
        }
    }
}

struct VPNCity: Codable {
    let name: String
    let code: String
    let latitude: Float
    let longitude: Float
    let servers: [VPNServer]
    let flagCode: String?
    //the higher the weight, the faster the server -> more likely the server is selected
    private(set) var selectedServer: VPNServer?

    init(name: String, code: String, latitude: Float, longitude: Float, servers: [VPNServer], flagCode: String) {
        self.name = name
        self.code = code
        self.latitude = latitude
        self.longitude = longitude
        self.servers = servers
        self.flagCode = flagCode

        setSelectedServer()
    }

    private mutating func setSelectedServer() {
        let weightSum = servers.reduce(0) {
            $0 + $1.weight
        }

        guard weightSum != 0 else {
            selectedServer = nil
            return
        }

        var r = Int.random(in: 0...weightSum)

        for server in servers {
            r -= server.weight

            if r <= 0 {
                selectedServer = server
                return
            }
        }
    }
}

extension VPNCity: Equatable {
    static func == (lhs: VPNCity, rhs: VPNCity) -> Bool {
        return lhs.name == rhs.name &&
            lhs.code == rhs.code &&
            lhs.latitude == rhs.latitude &&
            lhs.longitude == rhs.longitude &&
            lhs.flagCode == rhs.flagCode
    }
}

struct VPNServer: Codable, Equatable {
    let hostname: String
    let includeInCountry: Bool
    let publicKey: String
    let weight: Int
    let ipv4AddrIn: String
    let portRanges: [[Int]]
    let ipv4Gateway: String
    let ipv6Gateway: String

    enum CodingKeys: String, CodingKey {
        case hostname
        case includeInCountry = "include_in_country"
        case publicKey = "public_key"
        case weight
        case ipv4AddrIn = "ipv4_addr_in"
        case portRanges = "port_ranges"
        case ipv4Gateway = "ipv4_gateway"
        case ipv6Gateway = "ipv6_gateway"
    }

    var randomPort: Int? {
        return portRanges.flatMap { $0 }.randomElement()
    }
}

extension Array where Element == VPNCountry {
    func getRandomUSCity() -> VPNCity? {
        return first { $0.code.uppercased() == "US" }?.cities.randomElement()
    }

    func getRandomCity() -> VPNCity? {
        return randomElement()?.cities.randomElement()
    }
}
