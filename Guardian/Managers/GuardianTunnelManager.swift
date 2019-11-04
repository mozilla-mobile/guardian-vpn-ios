//
//  GuardianTunnelManager
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
    var timeSinceConnected: Double {
        return Date().timeIntervalSince(tunnel?.connection.connectedDate ?? Date())
    }
    private let keyStore = KeyStore.sharedStore
    private var tunnel: NETunnelProviderManager?
    
    private init() {
        loadTunnel()
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(self.vpnStatusDidChange(notification:)), name: Notification.Name.NEVPNStatusDidChange, object: nil)

            NotificationCenter.default.addObserver(self, selector: #selector(self.vpnConfigurationDidChange(notification:)), name: Notification.Name.NEVPNConfigurationChange, object: nil)
        }
    }
    
    func connect(with device: Device?) {
        loadTunnel { [weak self] in
            guard let self = self else { return }

            let tunnelProviderManager = self.tunnel ?? NETunnelProviderManager()
            guard let device = device else { return }

            tunnelProviderManager.setNewConfiguration(for: device, key: self.keyStore.deviceKeys.devicePrivateKey)
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

        tunnel.setNewConfiguration(for: device, key: keyStore.deviceKeys.devicePrivateKey)

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
