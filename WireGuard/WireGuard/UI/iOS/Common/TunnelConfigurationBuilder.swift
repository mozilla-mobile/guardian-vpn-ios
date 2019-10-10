// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

struct TunnelConfigurationBuilder {
    public static func createTunnelConfiguration(device: Device, city: VPNCity, privateKey: Data) -> TunnelConfiguration {
        // name
        let name = city.name

        // interface
        var interface = InterfaceConfiguration(privateKey: privateKey)
        let ipv4Address = IPAddressRange(from: device.ipv4Address)!
        let ipv6Address = IPAddressRange(from: device.ipv6Address)!
        interface.addresses = [ipv4Address, ipv6Address]

        // peers
        var peerConfigurations: [PeerConfiguration] = []

        for server in city.servers {
            var peerConfiguration = PeerConfiguration(publicKey: Data(base64Key: server.publicKey)!)
            peerConfiguration.endpoint = Endpoint(from: server.ipv4AddrIn + ":53") // Just adding port 53 for now.
            let serverIpv4Address = IPAddressRange(from: server.ipv4Gateway)!
            let serverIpv6Address = IPAddressRange(from: server.ipv6Gateway)!
            peerConfiguration.allowedIPs = [serverIpv4Address, serverIpv6Address]
            peerConfigurations.append(peerConfiguration)
        }

        return TunnelConfiguration(name: name, interface: interface, peers: peerConfigurations)
    }
}
