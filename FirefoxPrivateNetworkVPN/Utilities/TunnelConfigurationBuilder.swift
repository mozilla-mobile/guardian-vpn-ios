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
        if let ipv4Address = IPAddressRange(from: device.ipv4Address),
            let ipv6Address = IPAddressRange(from: device.ipv6Address) {
            interface.addresses = [ipv4Address, ipv6Address]
        }

        // peers
        var peerConfigurations: [PeerConfiguration] = []

        var serverCity = city

        if let server = serverCity.setServer(),
            let keyData = Data(base64Key: server.publicKey),
            let ipv4GatewayIP = IPv4Address(server.ipv4Gateway),
            let ipv6GatewayIP = IPv6Address(server.ipv6Gateway) {
            var peerConfiguration = PeerConfiguration(publicKey: keyData)
            let endpoint = Endpoint(from: server.ipv4AddrIn + ":\(server.randomPort ?? 53)")
            peerConfiguration.endpoint = endpoint
            peerConfiguration.allowedIPs = [
                IPAddressRange(address: IPv4Address("0.0.0.0")!, networkPrefixLength: 0),
                IPAddressRange(address: IPv6Address("::")!, networkPrefixLength: 0)
            ]
            peerConfigurations.append(peerConfiguration)
            interface.dns = [ DNSServer(address: ipv4GatewayIP),
                              DNSServer(address: ipv6GatewayIP) ]
        }

        return TunnelConfiguration(name: name, interface: interface, peers: peerConfigurations)
    }
}
