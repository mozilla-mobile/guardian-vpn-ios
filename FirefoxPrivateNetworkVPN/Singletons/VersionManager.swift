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

class VersionManager { //VersionMonitor?

    static let sharedManager = VersionManager()

    private static let timerInterval: TimeInterval = 21600
    private var timer: DispatchSourceTimer?

    //when subscribing make sure it gets latest and use distinct till change
    var versionUpdate = BehaviorRelay<VersionUpdate>(value: LatestVersion.fetchFromUserDefaults()?.update ?? VersionUpdate.none)

//    private var timeSinceLastPoll: TimeInterval {
//
//    }

    //move this somewhere else?
    func openAppStore() {

    }

    //call this from app entering foreground and background app delegate calls
    func start() {
//        let delay =

        //determine delay to start based on latestVersion date
        //if nothing saved in user defaults start checking
        //if latest saved version was greater than 6 hours ago start checking
        timer = DispatchSource.makeTimerSource()
        timer?.schedule(deadline: .now(), repeating: VersionManager.timerInterval, leeway: .seconds(1))
        timer?.setEventHandler { [weak self] in
            self?.pollLatestVersion()
        }
        timer?.activate()
    }

    func stop() {
        timer = nil
    }

    private func pollLatestVersion() {
        //make ballrog request to get latestVersion from response

        //update user defaults with response

        //publish nextVersion event with response
    }
}

enum VersionUpdate {
    case required
    case available
    case none
}

struct LatestVersion: UserDefaulting {
    static var userDefaultsKey = "LatestVersion"

    let version: String
    let required: Bool
    let dateRetrieved: Date

    var update: VersionUpdate {
        if version == UIApplication.appVersion {
            return .none
        } else if required {
            return .required
        } else {
            return .available
        }
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
