//
//  SimplePinger
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import os.log

protocol Pinging {
    func start(hostAddress: String)
    func stop()
}

class LongPinger: NSObject, Pinging, SimplePingDelegate {

    var pingInterval: TimeInterval = 1

    private var pinger: SimplePing?
    private var pingTimer: Timer?

    func start(hostAddress: String) {
        pinger = SimplePing(hostName: hostAddress)
        pinger?.delegate = self
        pinger?.start()
    }

    func stop() {
        pinger?.stop()
        pingTimer?.invalidate()
        pingTimer = nil
    }

    @objc func sendPing() {
        pinger?.send(with: nil)
    }

    public func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        sendPing()

        if pingTimer == nil {
            pingTimer = Timer.scheduledTimer(timeInterval: pingInterval, target: self, selector: #selector(sendPing), userInfo: nil, repeats: true)
        }
    }

    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        OSLog.log(.debug, "[%@] Ping was sent", args: Date().debugDescription)
    }
}
