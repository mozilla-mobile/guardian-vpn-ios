//
//  AppDelegate
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
        
        return true
    }
}
