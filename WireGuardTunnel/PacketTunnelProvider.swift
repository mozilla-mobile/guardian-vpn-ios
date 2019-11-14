//
//  PacketTunnelProvider
//  WireGuardTunnel
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
    private var handle: Int32?
    private var settingsGenerator: PacketTunnelSettingsGenerator?
    private var pathMonitor: NWPathMonitor?

    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {

        guard let tunnelConfig = (protocolConfiguration as? NETunnelProviderProtocol)?.asTunnelConfiguration(),
            tunnelConfig.peers.count == 1 else {
                OSLog.logTunnel(.error, "Unable to create single endpoint configuration")
                completionHandler(PacketTunnelProviderError.savedProtocolConfigurationIsInvalid)
                return
        }

        guard let endpoint = DNSResolver.resolveSync(endpoints: [tunnelConfig.peers.first?.endpoint])?.first else {
            OSLog.logTunnel(.error, "Unable to resolve host: %@", args: "\(tunnelConfig.peers.first?.endpoint?.host ?? "Unknown")")
            completionHandler(PacketTunnelProviderError.dnsResolutionFailure)
            return
        }

        let settingsGenerator = PacketTunnelSettingsGenerator(tunnelConfiguration: tunnelConfig, resolvedEndpoints: [endpoint])
        self.settingsGenerator = settingsGenerator

        setTunnelNetworkSettings(settingsGenerator.generateNetworkSettings()) { [weak self] error in
            guard error == nil else {
                OSLog.logTunnel(.error, "Unable to set tunnel network settings, error: %@", args: "\(error!)")
                completionHandler(PacketTunnelProviderError.couldNotSetNetworkSettings)
                return
            }
            self?.pathMonitor = NWPathMonitor()
            self?.pathMonitor?.pathUpdateHandler = { [weak self] path in
                if let handle = self?.handle,
                    let config = self?.settingsGenerator?.endpointUapiConfiguration() {
                    let configPtr = CFStringGetCStringPtr(config as CFString, CFStringBuiltInEncodings.UTF8.rawValue)
                    wgSetConfig(handle, gostring_t(p: configPtr, n: config.utf8.count))
                    wgBumpSockets(handle)
                }
            }
            self?.pathMonitor?.start(queue: DispatchQueue(label: "NWPathMonitor"))

            // Get the TUN interface file descriptor via key path.
            // This is a discouraged way of bypassing NEPacketTunnelFlow's read/write functions,
            // and the key path could change in future iOS versions.
            // Rewrite this to use NEPacketTunnelFlow as designed once wgTurnOn doesn't require
            // the file descriptor directly.
            // Ref: https://forums.developer.apple.com/thread/13503

            guard let fd = self?.packetFlow.value(forKeyPath: "socket.fileDescriptor") as? Int32 else {
                OSLog.logTunnel(.error, "Unable to get TUN interface file descriptor by key path.")
                completionHandler(PacketTunnelProviderError.couldNotDetermineFileDescriptor)
                return
            }

            guard fd >= 0 else {
                OSLog.logTunnel(.error, "Invalid TUN interface file descriptor: %@.", args: "\(fd)")
                completionHandler(PacketTunnelProviderError.couldNotDetermineFileDescriptor)
                return
            }

            if let config = self?.settingsGenerator?.uapiConfiguration() {
                let configPtr = CFStringGetCStringPtr(config as CFString, CFStringBuiltInEncodings.UTF8.rawValue)
                let handle = wgTurnOn(gostring_t(p: configPtr, n: config.utf8.count), fd)
                guard handle >= 0 else {
                    OSLog.logTunnel(.error, "Invalid handle returned from WireGuard: %@.", args: "\(handle)")
                    completionHandler(PacketTunnelProviderError.couldNotStartBackend)
                    return
                }
                self?.handle = handle
            }
            completionHandler(nil)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        pathMonitor?.cancel()
        if let handle = handle {
            wgTurnOff(handle)
        }
        completionHandler()
    }
}
