// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

class NavigationCoordinator: Navigating {

    let dependencyProvider: DependencyProviding
    let userManager = AccountManager.sharedManager
    var currentViewController: UIViewController?

    init(dependencyProvider: DependencyProviding) {
        self.dependencyProvider = dependencyProvider
    }

    func rootViewController() -> UIViewController {
        if let verification = VerifyResponse.fetchFromUserDefaults(),
            let device = Device.fetchFromUserDefaults() {
            let account = Account.init(user: verification.user, token: verification.token, device: device)
//            userManager.setup(with: verifyResponse, device: device)
//        }
//        if userManager.fetchSavedToken() {
//            userManager.fetchDevice()
            let loadingViewController = LoadingViewController(userManager: dependencyProvider.userManager, coordinatorDelegate: self)
            currentViewController = loadingViewController
            return loadingViewController
        } else {
            let loginViewController = LoginViewController(userManager: dependencyProvider.userManager, coordinatorDelegate: self)
            currentViewController = loginViewController
            return loginViewController
        }
    }

    // MARK: <NavigationProtocol>
    func navigate(after action: NavigationAction) {
        switch action {
        case .loginSucceeded:
            navigateToHomeVPN()
        case .loginFailed:
            navigateToLogin()
        case .vpnNewSelection(let countries):
            presentVPNLocationSelection(countries: countries)
        }
    }

    private func navigateToHomeVPN() {
        currentViewController = GuardianTabBarController(viewControllers: tabBarViewControllers)
        setKeyWindow(with: currentViewController!)
    }

    private func navigateToLogin() {
        currentViewController = LoginViewController(userManager: dependencyProvider.userManager, coordinatorDelegate: self)
        setKeyWindow(with: currentViewController!)
    }

    private func presentVPNLocationSelection(countries: [VPNCountry]? = nil) {
        let locationVPNVC = LocationVPNViewController(countries: countries, userManager: dependencyProvider.userManager)
        let navController = UINavigationController(rootViewController: locationVPNVC)
        navController.navigationBar.barTintColor = UIColor.backgroundOffWhite
        navController.navigationBar.tintColor = UIColor.guardianBlack
        currentViewController?.present(navController, animated: true, completion: nil)
    }

    private var tabBarViewControllers: [UIViewController] {
        let homeViewController = HomeVPNViewController(userManager: dependencyProvider.userManager, coordinatorDelegate: self)
        return [homeViewController]
    }

    private func setKeyWindow(with viewController: UIViewController) {
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
