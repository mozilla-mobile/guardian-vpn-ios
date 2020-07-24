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

import RxSwift
import RxCocoa

class ReleaseMonitor: ReleaseMonitoring {
    private static let timeInterval: TimeInterval = 21600
    private let guardianAPI: GuardianAPI
    private let accountStore: AccountStoring
    private var timer: DispatchSourceTimer?
    private var releaseInfo: ReleaseInfo?
    private var _updateStatus: BehaviorRelay<UpdateStatus?>

    var updateStatus: Observable<UpdateStatus?> {
        return _updateStatus.asObservable()
    }

    private var pollingDelay: DispatchTime {
        guard let latestRelease = releaseInfo else { return .now() }
        let delayInSeconds = ReleaseMonitor.timeInterval + latestRelease.dateRetrieved.timeIntervalSinceNow
        guard delayInSeconds > 0 else { return .now() }

        return .now() + DispatchTimeInterval.seconds(Int(delayInSeconds))
    }

    init(accountStore: AccountStoring, guardianAPI: GuardianAPI) {
        self.accountStore = accountStore
        self.guardianAPI = guardianAPI

        _updateStatus = BehaviorRelay<UpdateStatus?>(value: releaseInfo?.getUpdateStatus())
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
        guardianAPI.latestVersion { [weak self] response in
            guard case .success(let release) = response else { return }
            let releaseInfo = ReleaseInfo(with: release)
            self?.releaseInfo = releaseInfo
            self?.accountStore.save(releaseInfo: releaseInfo)

            self?._updateStatus.accept(releaseInfo.getUpdateStatus())
        }
    }
}
