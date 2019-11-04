//
//  VPNLocations
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

struct VPNCountry: Codable {
    let name: String
    let code: String
    let cities: [VPNCity]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        code = try container.decode(String.self, forKey: .code)

        // Turn [city[1, 2, 3]] into [city1, city2, city3]
        let multipleServerCities = try container.decode([VPNCity].self, forKey: .cities)
        var singleServerCities = [VPNCity]()
        for originalCity in multipleServerCities {
            for server in originalCity.servers {
                let newCity = VPNCity(
                    name: "\(originalCity.name) (\(server.hostname.split(separator: "-").first!))",
                    code: originalCity.code,
                    latitude: originalCity.latitude,
                    longitude: originalCity.longitude,
                    servers: [server]
                )
                singleServerCities.append(newCity)
            }
        }
        cities = singleServerCities
    }

    enum CodingKeys: String, CodingKey {
        case name
        case code
        case cities
    }
}

struct VPNCity: UserDefaulting {
    static var userDefaultsKey = "savedCity"

    let name: String
    let code: String
    let latitude: Float
    let longitude: Float
    let servers: [VPNServer]

    var isCurrentCity: Bool {
        return name == VPNCity.fetchFromUserDefaults()?.name
    }
}

struct VPNServer: Codable {
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
