// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

struct TunnelConfigurationBuilder {
    public static func createTunnelConfiguration(device: Device, city: VPNCity) -> TunnelConfiguration {
        let privateKey = Curve25519.generatePrivateKey()

        // name
        let name = city.name

        // interface
        var interface = InterfaceConfiguration(privateKey: privateKey)
        interface.listenPort = 53 // Does this come from the server?
        let ipv4Address = IPAddressRange(from: device.ipv4Address)!
        let ipv6Address = IPAddressRange(from: device.ipv6Address)!
        interface.addresses = [ipv4Address, ipv6Address]

        // peers
        var peerConfigurations: [PeerConfiguration] = []

        for server in city.servers {
            var peerConfiguration = PeerConfiguration(publicKey: server.publicKey.data(using: .utf8)!)
            peerConfiguration.endpoint = Endpoint(from: server.ipv4AddrIn)
            let serverIpv4Address = IPAddressRange(from: server.ipv4Gateway)!
            let serverIpv6Address = IPAddressRange(from: server.ipv6Gateway)!
            peerConfiguration.allowedIPs = [serverIpv4Address, serverIpv6Address]
            peerConfigurations.append(peerConfiguration)
        }

        return TunnelConfiguration(name: name, interface: interface, peers: peerConfigurations)
    }
}
