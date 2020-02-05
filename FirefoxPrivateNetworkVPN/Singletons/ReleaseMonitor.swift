//
//  VersionUpdateManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit
import RxSwift
import RxCocoa

class ReleaseMonitor: ReleaseMonitoring {
    static let sharedManager = ReleaseMonitor()

    private static let timeInterval: TimeInterval = 21600
    private var timer: DispatchSourceTimer?
    private var _updateStatus = BehaviorSubject<UpdateStatus?>(value: ReleaseInfo.fetchFromUserDefaults()?.getUpdateStatus())

    var updateStatus: Observable<UpdateStatus?> {
        return _updateStatus.asObservable()
    }

    private var pollingDelay: DispatchTime {
        guard let latestRelease = ReleaseInfo.fetchFromUserDefaults() else { return .now() }
        let delayInSeconds = ReleaseMonitor.timeInterval + latestRelease.dateRetrieved.timeIntervalSinceNow
        guard delayInSeconds > 0 else { return .now() }

        return .now() + DispatchTimeInterval.seconds(Int(delayInSeconds))
    }

    func start() {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: pollingDelay, repeating: ReleaseMonitor.timeInterval, leeway: .seconds(1))
        timer?.setEventHandler { [weak self] in
            self?.pollLatestVersion()
        }
        timer?.activate()
    }

    func stop() {
        timer = nil
    }

    private func pollLatestVersion() {
        GuardianAPI.latestVersion { [weak self] response in
            guard case .success(let release) = response else { return }
            let releaseInfo = ReleaseInfo(with: release)
            releaseInfo.saveToUserDefaults()

            self?._updateStatus.onNext(releaseInfo.getUpdateStatus())
        }
    }
}
