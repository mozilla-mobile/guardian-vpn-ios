//
//  TunnelConfigurationBuilder
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import Network

struct TunnelConfigurationBuilder {
    static func createTunnelConfiguration(device: Device, city: VPNCity, privateKey: Data) -> TunnelConfiguration? {
        // name
        let name = city.name

        // interface
        var interface = InterfaceConfiguration(privateKey: privateKey)
        let ipv4Address = IPAddressRange(from: device.ipv4Address)! // TODO: Handle force unwrap, return nils
        let ipv6Address = IPAddressRange(from: device.ipv6Address)!
        interface.addresses = [ipv4Address, ipv6Address]

        // peers
        var peerConfigurations: [PeerConfiguration] = []

        for server in city.servers {
            var peerConfiguration = PeerConfiguration(publicKey: Data(base64Key: server.publicKey)!) // TODO: dont force unwrap
            let endpoint = Endpoint(from: server.ipv4AddrIn + ":\(server.randomPort ?? 53)")
            peerConfiguration.endpoint = endpoint
            peerConfiguration.allowedIPs = [
                IPAddressRange(address: IPv4Address("0.0.0.0")!, networkPrefixLength: 0),
                IPAddressRange(address: IPv6Address("::")!, networkPrefixLength: 0)
            ]
            peerConfigurations.append(peerConfiguration)
            interface.dns = [ DNSServer(address: IPv4Address(server.ipv4Gateway)!),
                              DNSServer(address: IPv6Address(server.ipv6Gateway)!) ]
        }

        return TunnelConfiguration(name: name, interface: interface, peers: peerConfigurations)
    }
}
