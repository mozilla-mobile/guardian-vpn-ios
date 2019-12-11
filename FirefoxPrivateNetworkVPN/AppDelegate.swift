//
//  AppDelegate
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dependencyFactory: DependencyProviding?
    private let disposeBag = DisposeBag()

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        dependencyFactory = DependencyFactory.sharedFactory

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let firstViewController = dependencyFactory?.navigationCoordinator.firstViewController
        window.rootViewController = firstViewController
        window.makeKeyAndVisible()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dependencyFactory?.connectionHealthMonitor.reset()
        dependencyFactory?.accountManager.stopHeartbeat()
    }

    //swiftlint:disable trailing_closure
    func applicationWillEnterForeground(_ application: UIApplication) {
        if dependencyFactory?.accountManager.account != nil {
            dependencyFactory?.accountManager.startHeartbeat()
        }
        dependencyFactory?.tunnelManager.stateEvent
            .filter { $0 == .on }
            .take(1)
            .subscribe(onNext: { _ in
                if let hostAddress = VPNCity.fetchFromUserDefaults()?.servers.first?.ipv4Gateway {
                    self.dependencyFactory?.connectionHealthMonitor.start(hostAddress: hostAddress)
                }
            }).disposed(by: disposeBag)
    }
}
