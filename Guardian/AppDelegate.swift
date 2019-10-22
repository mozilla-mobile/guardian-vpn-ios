// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationCoordinator: NavigationCoordinator?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        self.window = window

        let dependencyProvider = DependencyFactory()
        navigationCoordinator = NavigationCoordinator(dependencyProvider: dependencyProvider)

        window.rootViewController = navigationCoordinator?.rootViewController
        window.makeKeyAndVisible()

        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        DependencyFactory.sharedFactory.accountManager.pollUser()
    }
}
