//
//  MacOSTunnelManager
//  MozillaVPNmacOS
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

extension TunnelsManager {

    var selectedTunnel: TunnelContainer? {
        return numberOfTunnels() > 0 ? tunnel(at: 0) : nil
    }
}

extension TunnelContainer {

    fileprivate var connectedDate: Date? {
        return tunnelProvider.connection.connectedDate
    }
}

class MacOSTunnelManager {

    private let tunnelsManager: TunnelsManager
    private let accountManager: AccountManager

    var selectedTunnel: TunnelContainer? {
        return tunnelsManager.selectedTunnel
    }

    var timeSinceConnected: Double {
        return Date().timeIntervalSince(tunnelsManager.selectedTunnel?.connectedDate ?? Date())
    }

    init(tunnelsManager: TunnelsManager, accountManager: AccountManager) {
        self.tunnelsManager = tunnelsManager
        self.accountManager = accountManager
    }

    func addVPNConfig() {
        guard let account = accountManager.account,
            let device = account.currentDevice,
            let city = accountManager.selectedCity else {
            return
        }

        let tunnelConfiguration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: account.privateKey)

         tunnelsManager.add(tunnelConfiguration: tunnelConfiguration) { result in
             switch result {
             case .failure(let error):
                 print("[Error] \(#function): \(error.alertText)")
             case .success:
                print("[Success] \(#function)")
             }
         }
    }

    func switchServer(city: VPNCity) {
        accountManager.updateSelectedCity(with: city)

        guard let account = accountManager.account,
            let device = account.currentDevice,
            let city = accountManager.selectedCity,
            let tunnel = tunnelsManager.selectedTunnel else {
            return
        }

        let tunnelConfiguration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: account.privateKey)

        tunnelsManager.modify(tunnel: tunnel, tunnelConfiguration: tunnelConfiguration, onDemandOption: .off) { error in
            if let error = error {
                print("[Error] \(#function): \(error.alertText)")
            } else {
                print("[Success] \(#function)")
            }
        }
    }

    func connect() {
        guard let tunnel = tunnelsManager.selectedTunnel else { return }
        if tunnel.status == .inactive {
            tunnelsManager.startActivation(of: tunnel)
        } else if tunnel.status == .active {
            tunnelsManager.startDeactivation(of: tunnel)
        }
    }

    func stop() {
        guard let tunnel = tunnelsManager.selectedTunnel else { return }
        tunnelsManager.startDeactivation(of: tunnel)
    }

    func remove() {
        guard let tunnel = tunnelsManager.selectedTunnel else { return }
        tunnelsManager.remove(tunnel: tunnel) { error in
            if let error = error {
                print("[ERROR] \(#function): \(error.alertText)")
            }
        }
    }

    func getReceivedBytes(completionHandler: @escaping ((UInt64?) -> Void)) {
        guard let tunnel = tunnelsManager.selectedTunnel else { return }
        tunnel.getRuntimeTunnelConfiguration { config in
            completionHandler(config?.peers.first?.rxBytes)
        }
    }
}
