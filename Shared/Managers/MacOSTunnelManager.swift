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

class MacOSTunnelManager {

    let tunnelsManager: TunnelsManager
    private let accountManager: AccountManager

    var timeSinceConnected: Double { 0.0 }

    init(tunnelsManager: TunnelsManager, accountManager: AccountManager) {
        self.tunnelsManager = tunnelsManager
        self.accountManager = accountManager
    }

    func connect() {
        guard let account = accountManager.account,
            let device = account.currentDevice,
            let city = accountManager.selectedCity else {
            print("[Error] accountManager data not found")
            return
       }

       let tunnelConfiguration = TunnelConfigurationBuilder.createTunnelConfiguration(device: device, city: city, privateKey: account.privateKey)

        tunnelsManager.add(tunnelConfiguration: tunnelConfiguration) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("[Error] \(#function): \(error.alertText)")
                return
            case .success(let tunnel):
                if tunnel.status == .inactive {
                    self.tunnelsManager.startActivation(of: tunnel)
                } else if tunnel.status == .active {
                    self.tunnelsManager.startDeactivation(of: tunnel)
                }
            }
        }
    }

    func switchServer(with device: Device) throws {

    }

    func stop() {
        let tunnel = tunnelsManager.tunnel(at: 0)
        tunnelsManager.startDeactivation(of: tunnel)
    }

    func stopAndRemove() {
        stop()
        let tunnel = tunnelsManager.tunnel(at: 0)
        tunnelsManager.remove(tunnel: tunnel) { error in
            if let error = error {
                print("[ERROR] \(#function): \(error.alertText)")
            }
        }
    }

    func getReceivedBytes(completionHandler: @escaping ((UInt64?) -> Void)) {
        let tunnel = tunnelsManager.tunnel(at: 0)
        tunnel.getRuntimeTunnelConfiguration { config in
            completionHandler(config?.peers.first?.rxBytes)
        }
    }
}
