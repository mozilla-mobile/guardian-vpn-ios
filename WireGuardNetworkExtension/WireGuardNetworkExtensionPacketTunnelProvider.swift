//
//  WireGuardNetworkExtensionPacketTunnelProvider
//  WireGuardNetworkExtension
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation
import NetworkExtension

class WireGuardNetworkExtensionPacketTunnelProvider: PacketTunnelProvider {

    override func startTunnel(options: [String: NSObject]?, completionHandler startTunnelCompletionHandler: @escaping (Error?) -> Void) {
        super.startTunnel(options: options) { error in
            if error == nil {
                if let isSwitchingInProgress = AppExtensionUserDefaults.standard.value(forKey: .isSwitchingInProgress) as? Bool,
                    !isSwitchingInProgress {
                    LocalNotificationFactory.shared.showNotification(when: .vpnConnected)
                }
            }
            startTunnelCompletionHandler(error)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        super.stopTunnel(with: reason) {
            if let isSwitchingInProgress = AppExtensionUserDefaults.standard.value(forKey: .isSwitchingInProgress) as? Bool,
                !isSwitchingInProgress {
                LocalNotificationFactory.shared.showNotification(when: .vpnDisconnected)
            }
            completionHandler()
        }
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)? = nil) {
        super.handleAppMessage(messageData, completionHandler: completionHandler)
    }
}
