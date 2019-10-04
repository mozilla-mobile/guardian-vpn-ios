// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class NavigationCoordinator: NavigationProtocol {
    static let sharedCoordinator = NavigationCoordinator()

    let userManager = UserManager.sharedManager
    var currentViewController: UIViewController?

    func rootViewController() -> UIViewController {
        if userManager.fetchSavedUserAndToken() {
            let tabBarController = GuardianTabBarController()
            currentViewController = tabBarController
            return tabBarController
        } else {
            let loginViewController = LoginViewController.init(nibName: String(describing: LoginViewController.self), bundle: Bundle.main)
            loginViewController.coordinatorDelegate = self
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
        let tabBarController = GuardianTabBarController()
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
}
