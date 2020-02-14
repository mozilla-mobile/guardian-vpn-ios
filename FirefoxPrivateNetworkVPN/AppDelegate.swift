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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var dependencyFactory: DependencyProviding?

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
        
        dependencyFactory?.releaseMonitor.start()

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        guard let dependencyFactory = dependencyFactory else { return }

        dependencyFactory.releaseMonitor.start()

        if dependencyFactory.accountManager.account != nil {
            dependencyFactory.accountManager.startHeartbeat()
        }

        if dependencyFactory.tunnelManager.stateEvent.value == .on,
            let hostAddress = VPNCity.fetchFromUserDefaults()?.servers.first?.ipv4Gateway {
            self.dependencyFactory?.connectionHealthMonitor.start(hostAddress: hostAddress)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dependencyFactory?.connectionHealthMonitor.stop()
        dependencyFactory?.accountManager.stopHeartbeat()
        dependencyFactory?.releaseMonitor.stop()
    }
}
