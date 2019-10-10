// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import NetworkExtension

class GuardianTunnelManager /* Jason's Tunnel */ {
    var tunnelProviderManagers = [NETunnelProviderManager]()

    init() {
        loadTunnels()
    }

    func loadTunnels() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            guard let self = self else { return }
            if let managers = managers {
                self.tunnelProviderManagers = managers
            }
            print("\(self.tunnelProviderManagers.count) tunnels available")
        }
    }

    func createTunnel(device: Device, city: VPNCity, privateKey: Data) {
        let tunnelConfiguration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: privateKey)

        let tunnelProviderManager = NETunnelProviderManager()
        let tunnelProviderProtocol = NETunnelProviderProtocol()

        guard let ipv4Address = city.servers.randomElement()?.ipv4AddrIn else { return } // UNSURE

        tunnelProviderProtocol.providerBundleIdentifier = "Connected.Guardian" // TODO: Change this
        tunnelProviderProtocol.serverAddress = ipv4Address
        tunnelProviderProtocol.providerConfiguration?["WgQuickConfig"] = tunnelConfiguration.asWgQuickConfig()
        tunnelProviderManager.protocolConfiguration = tunnelProviderProtocol
        tunnelProviderManager.localizedDescription = "Firefox Guardian"
        tunnelProviderManager.isEnabled = true

        tunnelProviderManager.saveToPreferences { error in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            //                    guard let self = self else { return }
            do {
                try (tunnelProviderManager.connection as? NETunnelProviderSession)?.startTunnel()
            } catch let error {
                print("Error: \(error)")
            }
        }
    }

    func startTunnel() {
        guard let tunnelProviderManager = tunnelProviderManagers.first else {
            print("No tunnels to start")
            return
        }
        do {
            try (tunnelProviderManager.connection as? NETunnelProviderSession)?.startTunnel()
        } catch let error {
            print("Error: \(error)")
        }
    }

    func annihilateTunnel() {
        guard let connectedTunnelProvider = self.tunnelProviderManagers.first(where: { $0.connection.status == .connected }) else {
            print("No tunnel is connected")
            return
        }
        (connectedTunnelProvider.connection as? NETunnelProviderSession)?.stopTunnel()
    }
}
