// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import NetworkExtension

class GuardianTunnelManager {
    static let sharedTunnelManager = GuardianTunnelManager()

    var tunnelProviderManager: NETunnelProviderManager?
    var tunnelConfiguration: TunnelConfiguration?

    private init() {
        loadTunnels()

        NotificationCenter.default.addObserver(self, selector: #selector(vpnStatusDidChange(notification:)), name: Notification.Name.NEVPNStatusDidChange, object: nil)

    }

    func loadTunnels() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            guard let self = self else { return }
            if let first = managers?.first {
                self.tunnelProviderManager = first
            } else {
                self.tunnelProviderManager = NETunnelProviderManager()
            }
        }
    }

    func createTunnel(accountManager: AccountManaging?) { // Inject Account Manager or pass in device?
        guard let device = accountManager?.account?.currentDevice,
            let privateKey = (accountManager as? AccountManager)?.credentialsStore.deviceKeys.devicePrivateKey
            else { return }
        // get current city / config
        // TODO: Save city somewhere, and retrieve it here.
        guard let currentCity = VPNCity.fetchFromUserDefaults() else { return }

        createTunnel(device: device, city: currentCity, privateKey: privateKey)
    }

    func createTunnel(device: Device, city: VPNCity, privateKey: Data) {
        tunnelConfiguration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: privateKey)
        if tunnelProviderManager?.connection.status == .connected || tunnelProviderManager?.connection.status == .connecting {
            stopTunnel()
        } else {
            guard let tunnelConfiguration = tunnelConfiguration else { return }
            createTunnel(from: tunnelConfiguration)
        }
    }

    private func createTunnel(from configuration: TunnelConfiguration) {
        guard let tunnelProviderManager = tunnelProviderManager else { return }
        let tunnelProviderProtocol = NETunnelProviderProtocol(tunnelConfiguration: configuration)

        tunnelProviderManager.protocolConfiguration = tunnelProviderProtocol
        tunnelProviderManager.localizedDescription = tunnelConfiguration?.name ?? "My Tunnel"
        tunnelProviderManager.isEnabled = true

        // TODO: Do we want this on demand connect?
        let rule = NEOnDemandRuleConnect()
        rule.interfaceTypeMatch = .any
        rule.ssidMatch = nil
        tunnelProviderManager.onDemandRules = [rule]
        tunnelProviderManager.isOnDemandEnabled = false

        tunnelProviderManager.saveToPreferences { _ in
            tunnelProviderManager.loadFromPreferences { error in
                guard error == nil else {
                    print("Error: \(error!)")
                    return
                }
                do {
                    try (tunnelProviderManager.connection as? NETunnelProviderSession)?.startTunnel()
                } catch let error {
                    print("Start Tunnel Error: \(error)")
                }
            }
        }
    }

    @objc func vpnStatusDidChange(notification: Notification) {
        guard let tunnelConfiguration = tunnelConfiguration else { return }
        guard let status = (notification.object as? NETunnelProviderSession)?.status else { return }

        print("#### STATUS: \(status.rawValue)")
        switch status {
        case .disconnected:
            createTunnel(from: tunnelConfiguration)
        default:
            break
        }
    }

    func startTunnel() {
        guard let tunnelProviderManager = tunnelProviderManager else { return }
        do {
            try (tunnelProviderManager.connection as? NETunnelProviderSession)?.startTunnel()
        } catch let error {
            print("Error: \(error)")
        }
    }

    func stopTunnel() {
        guard let tunnelProviderManager = tunnelProviderManager else { return }
        (tunnelProviderManager.connection as? NETunnelProviderSession)?.stopTunnel()
    }
}
