//
//  NavigationCoordinator
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

// TODO: Add back heartbeat.

import UIKit

enum NavigableItem {
    case about
    case carousel
    case devices
    case help
    case home
    case landing
    case loading
    case login
    case servers
    case settings
    case tab
}

class NavigationCoordinator: NavigationCoordinating {
    static let sharedCoordinator: NavigationCoordinating = {
        let instance = NavigationCoordinator()
        //
        return instance
    }()

    private var currentViewController: (UIViewController & Navigating)?
    private weak var appDelegate = UIApplication.shared.delegate as? AppDelegate

    var firstViewController: UIViewController {
        let loadingViewController = LoadingViewController()
        currentViewController = loadingViewController
        return loadingViewController
    }

    private init() { }

    func navigate(from origin: NavigableItem, to destination: NavigableItem, context: [String: Any?]?) {
        DispatchQueue.main.async { [weak self] in
            switch (origin, destination) {
                // To Landing
            case (.loading, .landing), (.login, .landing), (.settings, .landing):
                let landingViewController = LandingViewController()
                self?.appDelegate?.window?.rootViewController = landingViewController
                self?.currentViewController = landingViewController

                // To Home for the first time
            case (.loading, .home), (.landing, .home), (.login, .home):
                let tabBarController = GuardianTabBarController()
                tabBarController.displayTab(.home)
                self?.appDelegate?.window?.rootViewController = tabBarController
                self?.currentViewController = tabBarController

                guard let user = DependencyFactory.sharedFactory.accountManager.user else { return }
                if user.hasTooManyDevices {
                    self?.navigate(from: .home, to: .settings)
                    self?.navigate(from: .settings, to: .devices)
                }

                // To Home
            case (.settings, .home), (.tab, .home):
                (self?.currentViewController as? GuardianTabBarController)?.displayTab(.home)

                // To Servers
            case (.home, .servers):
                let serversViewController = ServersViewController()
                let navController = UINavigationController(rootViewController: serversViewController)
                navController.navigationBar.barTintColor = UIColor.custom(.grey5)
                navController.navigationBar.tintColor = UIColor.custom(.grey50)
                self?.currentViewController?.present(navController, animated: true, completion: nil)

                // To Settings
            case (.home, .settings), (.tab, .settings):
                (self?.currentViewController as? GuardianTabBarController)?.displayTab(.settings)

                // To Login
            case (.landing, .login):
                let loginViewController = LoginViewController()
                self?.appDelegate?.window?.rootViewController = loginViewController
                self?.currentViewController = loginViewController
                
                // To Devices
            case (.settings, .devices):
                let devicesViewController = DeviceManagementViewController()
                let navController = (self?.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.pushViewController(devicesViewController, animated: true)
                 
            default: // You can't get there from here.
                // Breakpoint here to catch unhandled transitions
                return
            }
        }
    }
}
