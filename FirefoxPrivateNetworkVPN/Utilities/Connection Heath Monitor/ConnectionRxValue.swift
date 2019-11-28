//
//  ConnectionRxValue
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import RxSwift
import os.log

protocol ConnectionRxValueObserving {
    var rx: Observable<UInt> { get }
}

class ConnectionRxValue: ConnectionRxValueObserving {

    private static let timerInternal: TimeInterval = 1

    private let tunnelManager = DependencyFactory.sharedFactory.tunnelManager
    private var timer: Timer?

    var rx: Observable<UInt> {
        return .create { [weak self] observer -> Disposable in
            guard let self = self else { return Disposables.create() }

            self.timer = Timer.scheduledTimer(withTimeInterval: ConnectionRxValue.timerInternal, repeats: true) { [weak self] _ in
                self?.tunnelManager.getReceivedBytes { rxValue in
                    guard let rxValue = rxValue else { return }

                    OSLog.log(.debug, "Rx value retrieved: \(rxValue)")
                    observer.on(.next(rxValue))
                }
            }

            return Disposables.create { [weak self] in
                self?.timer?.invalidate()
                self?.timer = nil
            }
        }
    }
}
