// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation
import NetworkExtension
import RxSwift
import RxCocoa

class GuardianTunnelManager {
    static let sharedTunnelManager = GuardianTunnelManager()
    let keyStore = KeyStore.sharedStore
    var cityChangedEvent = PublishSubject<VPNCity>()
    var statusChangedEvent = PublishSubject<NEVPNStatus>()
    public var isSwitching = BehaviorRelay<Bool>(value: false)
    private var tunnel: NETunnelProviderManager?

    public var currentStatus: NEVPNStatus {
        return tunnel?.connection.status ?? .disconnected
    }
    public var timeSinceConnected: Double {
        return Date().timeIntervalSince(tunnel?.connection.connectedDate ?? Date())
    }

    private init() {
        loadTunnel()
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(self.vpnStatusDidChange(notification:)), name: Notification.Name.NEVPNStatusDidChange, object: nil)

            NotificationCenter.default.addObserver(self, selector: #selector(self.vpnConfigurationDidChange(notification:)), name: Notification.Name.NEVPNConfigurationChange, object: nil)
        }
    }

    // MARK: Public Functions

    public func switchServer(with device: Device) { //add completion?

        guard let city = VPNCity.fetchFromUserDefaults() else { return }
        guard let newConfiguration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: keyStore.deviceKeys.devicePrivateKey) else { return }

        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                let tunnel = self.tunnel else { return }
            if (self.currentStatus != .disconnected) != self.isSwitching.value {
                self.isSwitching.accept(self.currentStatus != .disconnected)
            }
            tunnel.protocolConfiguration = NETunnelProviderProtocol(tunnelConfiguration: newConfiguration)
            tunnel.localizedDescription = newConfiguration.name ?? "My Tunnel"
            tunnel.saveToPreferences { saveError in
                if let error = saveError {
                    print(error)
                    if self.isSwitching.value {
                        self.isSwitching.accept(false)
                    }
                    return
                }

                tunnel.loadFromPreferences { error in
                    if let error = error { print(error) }
                }
            }
        }
    }

    public func connect(with device: Device?) {
        if tunnel != nil {
            startTunnel()
            return
        }

        guard let device = device,
            let city = VPNCity.fetchFromUserDefaults() else { return }

        guard let configuration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: keyStore.deviceKeys.devicePrivateKey) else { return }

        let tunnelProviderProtocol = NETunnelProviderProtocol(tunnelConfiguration: configuration)
        let tunnelProviderManager = NETunnelProviderManager()
        tunnelProviderManager.protocolConfiguration = tunnelProviderProtocol
        tunnelProviderManager.localizedDescription = configuration.name ?? "My Tunnel"
        tunnelProviderManager.isEnabled = true

        let rule = NEOnDemandRuleConnect()
        rule.interfaceTypeMatch = .any
        rule.ssidMatch = nil
        tunnelProviderManager.onDemandRules = [rule]
        tunnelProviderManager.isOnDemandEnabled = false

        tunnelProviderManager.saveToPreferences { [unowned self] saveError in
            if saveError != nil { return }
            self.tunnel = tunnelProviderManager
            self.tunnel?.loadFromPreferences { error in
                guard error == nil else { return }
                self.startTunnel()
            }
        }
    }

    public func stopTunnel() {
        guard let tunnel = tunnel else { return }
        (tunnel.connection as? NETunnelProviderSession)?.stopTunnel()
    }

    public func removeTunnel() {
        if let tunnel = tunnel {
            tunnel.removeFromPreferences { _ in
                DispatchQueue.main.async { }
            }
        }
    }

    // MARK: Private Helper Fuctions

    private func loadTunnel() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard let self = self, error == nil else { return }
            let lastUsedServer = managers?.filter { manager in
                //need to fix this once see whats on manager
                return manager.localizedDescription == VPNCity.fetchFromUserDefaults()?.name
            }
            self.tunnel = lastUsedServer?.first
        }
    }

    private func startTunnel() {
        guard let tunnel = tunnel else { return }
        do {
            try (tunnel.connection as? NETunnelProviderSession)?.startTunnel()
        } catch let error {
            print("Error: \(error)")
        }
    }

     // MARK: NotificationCenter

    @objc func vpnConfigurationDidChange(notification: Notification) {
        let object = notification.object
        print("\(object ?? "no object:") \(notification)")
        if isSwitching.value {
            stopTunnel()
        }
    }

    @objc func vpnStatusDidChange(notification: Notification) {
        guard let session = (notification.object as? NETunnelProviderSession) else { return }
        let status = session.status
        if case .disconnected = status, isSwitching.value {
            startTunnel()
        } else if case .connected = status {
            isSwitching.accept(false)
        }
        statusChangedEvent.onNext(status)
    }
}
