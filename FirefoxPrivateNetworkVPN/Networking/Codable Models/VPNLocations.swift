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

struct VPNCity: UserDefaulting, Equatable {
    static var userDefaultsKey = "savedCity"

    let name: String
    let code: String
    let latitude: Float
    let longitude: Float
    let servers: [VPNServer]
    let flagCode: String?

    //the higher the weight, the faster the server
    //randomly selects one of the servers with the highest weights
    var fastestServer: VPNServer? {
        let maxWeightedServer = servers.max { $0.weight < $1.weight }
        guard let maxWeight = maxWeightedServer?.weight else {
            return nil
        }

        return servers.filter { return $0.weight == maxWeight }.randomElement()
    }

    var isCurrentCity: Bool {
        return self == VPNCity.fetchFromUserDefaults()
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

extension Array: UserDefaulting where Element == VPNCountry {
    static var userDefaultsKey: String {
        "serverList"
    }

    func getRandomUSCity() -> VPNCity? {
        return first { $0.code.uppercased() == "US" }?.cities.randomElement()
    }

    func getRandomCity() -> VPNCity? {
        return randomElement()?.cities.randomElement()
    }
}
