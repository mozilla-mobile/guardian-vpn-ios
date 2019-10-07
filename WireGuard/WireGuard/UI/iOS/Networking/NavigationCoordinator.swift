// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class NavigationCoordinator: NavigationProtocol {
    let dependencyProvider: DependencyProviding

    let userManager = UserManager.sharedManager
    var currentViewController: UIViewController?

    init(dependencyProvider: DependencyProviding) {
        self.dependencyProvider = dependencyProvider
    }

    func rootViewController() -> UIViewController {
        if userManager.fetchSavedUserAndToken() {
            let tabBarController = GuardianTabBarController(viewControllers: loggedInViewControllers)
            currentViewController = tabBarController
            return tabBarController
        } else {
            let loginViewController = LoginViewController(userManager: dependencyProvider.userManager, coordinatorDelegate: self)
            currentViewController = loginViewController
            return loginViewController
        }
    }

    // MARK: <NavigationProtocol>
    func navigate(after action: NavigationAction) {
        switch action {
        case .manualLoginSucceeded:
            navigateToHomeVPN()
        case .vpnNewSelection:
            presentVPNLocationSelection()
        }
    }

    private func navigateToHomeVPN() {
        let tabBarController = GuardianTabBarController(viewControllers: loggedInViewControllers)
        currentViewController = tabBarController

        if let window = UIApplication.shared.keyWindow {
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }

    private func presentVPNLocationSelection() {
        let locationVPNVC = LocationVPNViewController.init(nibName: String(describing: LocationVPNViewController.self), bundle: Bundle.main)
        let navController = UINavigationController(rootViewController: locationVPNVC)
        navController.navigationBar.barTintColor = UIColor.backgroundOffWhite
        navController.navigationBar.tintColor = UIColor.guardianBlack
        currentViewController?.present(navController, animated: true, completion: nil)
    }

    private var loggedInViewControllers: [UIViewController] {
        let homeViewController = HomeVPNViewController(userManager: dependencyProvider.userManager, coordinatorDelegate: self)
        return [homeViewController]
    }
}
