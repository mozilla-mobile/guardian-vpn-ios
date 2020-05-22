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
    var dependencyManager: DependencyProviding?

    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        dependencyManager = DependencyManager.shared

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        let firstViewController = dependencyManager?.navigationCoordinator.firstViewController
        window.rootViewController = firstViewController
        window.makeKeyAndVisible()

        dependencyManager?.releaseMonitor.start()

        Logger.configureGlobal(tagged: "APP", withFilePath: FileManager.logFileURL?.path)

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        guard let dependencyManager = dependencyManager else { return }

        dependencyManager.releaseMonitor.start()

        if dependencyManager.accountManager.account != nil {
            dependencyManager.heartbeatMonitor.start()
        }

        if dependencyManager.tunnelManager.stateEvent.value == .on,
            let hostAddress = dependencyManager.accountManager.selectedCity?.selectedServer?.ipv4Gateway {
            self.dependencyManager?.connectionHealthMonitor.start(hostAddress: hostAddress)
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .pad ? .all : [.portrait, .portraitUpsideDown]
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dependencyManager?.connectionHealthMonitor.stop()
        dependencyManager?.heartbeatMonitor.stop()
        dependencyManager?.releaseMonitor.stop()
    }
}
