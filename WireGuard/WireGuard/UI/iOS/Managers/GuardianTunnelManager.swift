// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import NetworkExtension

class GuardianTunnelManager {
    static let sharedTunnelManager = GuardianTunnelManager()

    var tunnelProviderManager: NETunnelProviderManager?
    var tunnelConfiguration: TunnelConfiguration?
    var vpnStoppedSemaphore: DispatchSemaphore?


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

    func createTunnel(accountManager: AccountManaging?) {
        guard let device = accountManager?.account?.currentDevice, // current device is nil on first launch.
            let privateKey = accountManager?.credentialsStore.deviceKeys.devicePrivateKey
            else { return }

        guard let city = VPNCity.fetchFromUserDefaults() else { return }

        tunnelConfiguration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: privateKey)

        DispatchQueue.global().async { [weak self] in
            if self?.tunnelProviderManager?.connection.status == .connected || self?.tunnelProviderManager?.connection.status == .connecting {
                self?.stopTunnel()
                self?.vpnStoppedSemaphore = DispatchSemaphore(value: 0)
                _ = self?.vpnStoppedSemaphore?.wait(timeout: DispatchTime.now() + DispatchTimeInterval.milliseconds(2 * 1000))
            }
            guard let tunnelConfiguration = self?.tunnelConfiguration else { return }
            self?.createTunnel(from: tunnelConfiguration)
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
        guard let status = (notification.object as? NETunnelProviderSession)?.status else { return }

        switch status {
        case .disconnected:
            vpnStoppedSemaphore?.signal()
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
