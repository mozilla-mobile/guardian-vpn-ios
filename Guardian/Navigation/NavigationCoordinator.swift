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
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var firstViewController: UIViewController {
        let loadingViewController = LoadingViewController()
        currentViewController = loadingViewController
        return loadingViewController
    }
    
    private init() { }
    
    func navigate(from origin: NavigableItem, to destination: NavigableItem, context: [String: Any?]?) {
        DispatchQueue.main.async { [weak self] in
            switch (origin, destination) {
            case (.loading, .landing):
                let landingViewController = LandingViewController()
                self?.appDelegate?.window?.rootViewController = landingViewController
                self?.currentViewController = landingViewController
            case (.loading, .home), (.landing, .home):
                let tabBarController = GuardianTabBarController()
                tabBarController.displayTab(.home)
                self?.appDelegate?.window?.rootViewController = tabBarController
                self?.currentViewController = tabBarController
            case (.home, .servers):
                let serversViewController = ServersViewController()
                self?.currentViewController?.present(serversViewController, animated: true, completion: nil)
            case (.home, .settings), (.tab, .settings):
                (self?.currentViewController as? GuardianTabBarController)?.displayTab(.settings)
            case (.settings, .home), (.tab, .home):
                (self?.currentViewController as? GuardianTabBarController)?.displayTab(.home)
            default:
                // Breakpoint here to catch unhandled transitions
                return
            }
        }
    }
}
