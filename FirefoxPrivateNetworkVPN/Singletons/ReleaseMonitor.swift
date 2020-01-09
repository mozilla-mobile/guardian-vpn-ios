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
    private static let urlRequest = ReleaseUpdateURLRequest.urlRequest()

    var releaseStatus = BehaviorRelay<LatestReleaseStatus?>(value: LatestRelease.fetchFromUserDefaults()?.status)

    private var pollingDelay: DispatchTime? {
        guard let latestRelease = LatestRelease.fetchFromUserDefaults() else { return nil }
        let delayInSeconds = ReleaseMonitor.timeInterval + latestRelease.dateRetrieved.timeIntervalSinceNow
        guard delayInSeconds > 0 else { return nil }

        return .now() + DispatchTimeInterval.seconds(Int(delayInSeconds))
    }

    func start() {
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: pollingDelay ?? .now(), repeating: ReleaseMonitor.timeInterval, leeway: .seconds(1))
        timer?.setEventHandler { [weak self] in
            self?.pollLatestVersion()
        }
        timer?.activate()
    }

    func stop() {
        timer = nil
    }

    private func pollLatestVersion() {
        NetworkLayer.fire(urlRequest: ReleaseMonitor.urlRequest) { [weak self] response in
            guard case .success(let release) = response.decode(to: Release.self) else { return }
            let latestRelease = LatestRelease(with: release)
            latestRelease.saveToUserDefaults()

            self?.releaseStatus.accept(latestRelease.status)
        }
    }
}
