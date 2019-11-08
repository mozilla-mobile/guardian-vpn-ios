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
<<<<<<< HEAD

                // To Home for the first time
=======
                
            // To Home
>>>>>>> 717a56019c2693e04d9a397ab384c39aaff3777a
            case (.loading, .home), (.landing, .home), (.login, .home):
                let tabBarController = GuardianTabBarController()
                tabBarController.displayTab(.home)
                self?.appDelegate?.window?.rootViewController = tabBarController
                self?.currentViewController = tabBarController

                guard let user = DependencyFactory.sharedFactory.accountManager.user else { return }
                if user.hasTooManyDevices {
                    self?.navigate(from: .home, to: .settings)
                    self?.navigate(from: .settings, to: .devices)
                    disableHomeTab()
                }

                // To Home
            case (.settings, .home), (.tab, .home):
                (self?.currentViewController as? GuardianTabBarController)?.displayTab(.home)

<<<<<<< HEAD
                // To Servers
=======
            // To Servers
>>>>>>> 717a56019c2693e04d9a397ab384c39aaff3777a
            case (.home, .servers):
                let serversViewController = ServersViewController()
                let navController = UINavigationController(rootViewController: serversViewController)
                navController.navigationBar.barTintColor = UIColor.custom(.grey5)
                navController.navigationBar.tintColor = UIColor.custom(.grey50)
                self?.currentViewController?.present(navController, animated: true, completion: nil)
                
            // To Settings
            case (.home, .settings), (.tab, .settings):
                (self?.currentViewController as? GuardianTabBarController)?.displayTab(.settings)
<<<<<<< HEAD
            case (.devices, .settings):
                let navController = (self?.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.popViewController(animated: true)
=======

            case (.devices, .settings), (.about, .settings), (.help, .settings):
                let navController = (self?.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.popViewController(animated: true)

            // To Home
            case (.settings, .home), (.tab, .home):
                (self?.currentViewController as? GuardianTabBarController)?.displayTab(.home)
>>>>>>> 717a56019c2693e04d9a397ab384c39aaff3777a

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

            // To Help
            case (.settings, .help):
                let helpViewController = GetHelpViewController()
                let navController = (self?.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.pushViewController(helpViewController, animated: true)

            // To About
            case (.settings, .about):
                let aboutViewController = AboutViewController()
                let navController = (self?.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.pushViewController(aboutViewController, animated: true)
                 
            default: // You can't get there from here.
                // Breakpoint here to catch unhandled transitions
                return
            }
        }
    }
    
    func disableHomeTab() {
//        tabBarController.tabBar.items?[0].isEnabled = false
    }
}
