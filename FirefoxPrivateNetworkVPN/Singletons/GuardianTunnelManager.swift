//
//  GuardianTunnelManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import NetworkExtension
import RxSwift
import RxRelay

class GuardianTunnelManager: TunnelManaging {
    static let sharedManager: TunnelManaging = {
        let instance = GuardianTunnelManager()
        //
        return instance
    }()

    private(set) var cityChangedEvent = PublishSubject<VPNCity>()
    private(set) var stateEvent = BehaviorRelay<VPNState>(value: .off)
    private let account = DependencyFactory.sharedFactory.accountManager.account
    private var tunnel: NETunnelProviderManager?

    var timeSinceConnected: Double {
        return Date().timeIntervalSince(tunnel?.connection.connectedDate ?? Date())
    }

    private init() {
        loadTunnel {
            guard let tunnel = self.tunnel else {
                self.stateEvent.accept(.off)
                return
            }
            self.stateEvent.accept(VPNState(with: tunnel.connection.status))
        }

        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(self.vpnStatusDidChange(notification:)), name: Notification.Name.NEVPNStatusDidChange, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.vpnConfigurationDidChange(notification:)), name: Notification.Name.NEVPNConfigurationChange, object: nil)
        }
    }

    func connect(with device: Device?) {
        loadTunnel { [weak self] in
            guard let self = self else { return }

            let tunnelProviderManager = self.tunnel ?? NETunnelProviderManager()
            guard let device = device, let account = self.account else { return }

            tunnelProviderManager.setNewConfiguration(for: device, key: account.privateKey)
            tunnelProviderManager.isEnabled = true

            tunnelProviderManager.saveToPreferences { [unowned self] saveError in
                guard saveError == nil else {
                    self.tunnel = nil
                    return
                }
                self.tunnel = tunnelProviderManager
                self.tunnel?.loadFromPreferences { error in
                    guard error == nil else { return }
                    self.startTunnel()
                }
            }
        }
    }

    func stop() {
        guard let tunnel = tunnel else { return }
        (tunnel.connection as? NETunnelProviderSession)?.stopTunnel()
    }

    func switchServer(with device: Device) {
        guard let tunnel = self.tunnel else {
            connect(with: device)
            return
        }

        if self.stateEvent.value != .off {
            self.stateEvent.accept(.switching)
        }
        guard let account = self.account else { return }
        tunnel.setNewConfiguration(for: device, key: account.privateKey)

        tunnel.saveToPreferences { saveError in
            guard saveError == nil else {
                if self.stateEvent.value == .switching {
                    self.stateEvent.accept(.on)
                }
                return
            }

            tunnel.loadFromPreferences { error in
                // TODO: Handle errors, don't print
                if let error = error { print(error) }
            }
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

    private func loadTunnel(completion: (() -> Void)? = nil) {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard let self = self, error == nil else { return }
            self.tunnel = managers?.first { $0.localizedDescription == VPNCity.fetchFromUserDefaults()?.name }
            completion?()
        }
    }

    private func removeTunnel() {
        guard let tunnel = tunnel else { return }
        tunnel.removeFromPreferences { _ in
            self.tunnel = nil
            NETunnelProviderManager.loadAllFromPreferences { _, _ in }
        }
    }

    @objc private func vpnConfigurationDidChange(notification: Notification) {
        if stateEvent.value == .switching {
            stop()
        }
    }

    @objc private func vpnStatusDidChange(notification: Notification) {
        guard let session = (notification.object as? NETunnelProviderSession), tunnel?.connection == session else { return }

        if stateEvent.value == .switching {
            switch session.status {
            case .disconnecting, .connecting:
                return
            case .disconnected:
                startTunnel()
                return
            default:
                break
            }
        }
        stateEvent.accept(VPNState(with: session.status))
    }
}

private extension NETunnelProviderManager {
    func setNewConfiguration(for device: Device, key: Data) {
        guard let city = VPNCity.fetchFromUserDefaults() else { return }
        guard let newConfiguration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: key) else { return }

        self.protocolConfiguration = NETunnelProviderProtocol(tunnelConfiguration: newConfiguration)
        self.localizedDescription = newConfiguration.name ?? city.name
    }
}
