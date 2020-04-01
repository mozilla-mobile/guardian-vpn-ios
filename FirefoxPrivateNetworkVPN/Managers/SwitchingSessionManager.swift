//
//  SwitchingSessionManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation
import NetworkExtension

class SwitchingSessionManager {
    private let timeoutAfter: DispatchTimeInterval = .seconds(20)
    private var timer: DispatchSourceTimer?
    private var completion: ((NEVPNStatus) -> Void)
    
    init(completion: @escaping ((NEVPNStatus) -> Void)) {
        self.completion = completion
    }
    
    func update(with status: NEVPNStatus) {
        startTimerIfNeeded()
        switch status {
        case .connected:
            finish(with: status)
        case .disconnected:
            if timer != nil {
                do {
                    try DependencyManager.shared.tunnelManager.startTunnel()
                } catch {
                    finish(with: status)
                }
            }
        default: break
        }
    }
    
    private func startTimerIfNeeded() {
        if timer == nil {
            timer = DispatchSource.makeTimerSource()
            timer?.schedule(deadline: .now() + timeoutAfter, repeating: .never, leeway: .seconds(1))
            timer?.setEventHandler { [weak self] in
                self?.finish(with: .disconnected)
            }
            timer?.activate()
        }
    }

    private func finish(with status: NEVPNStatus) {
        timer = nil
        DispatchQueue.main.async { [unowned self] in
            self.completion(status)
        }
    }
}
