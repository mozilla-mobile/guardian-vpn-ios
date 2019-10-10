// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class NavigationCoordinator: Navigating {

    let dependencyProvider: DependencyProviding
    var currentViewController: UIViewController?

    init(dependencyProvider: DependencyProviding) {
        self.dependencyProvider = dependencyProvider
        if let verification = VerifyResponse.fetchFromUserDefaults() {
            dependencyProvider.accountManager.set(with: Account.init(user: verification.user,
                                                                     token: verification.token))
            if let device = Device.fetchFromUserDefaults() {
                dependencyProvider.accountManager.account?.currentDevice = device
            }
        }
    }

    func rootViewController() -> UIViewController {
        guard dependencyProvider.accountManager.account != nil else {
            let loginViewController = LoginViewController(accountManager: dependencyProvider.accountManager, coordinatorDelegate: self)
            currentViewController = loginViewController
            return loginViewController
        }

        let loadingViewController = LoadingViewController(accountManager: dependencyProvider.accountManager, coordinatorDelegate: self)
        currentViewController = loadingViewController
        return loadingViewController
    }

    // MARK: <NavigationProtocol>
    func navigate(after action: NavigationAction) {
        switch action {
        case .loginSucceeded:
            navigateToHomeVPN()
        case .loginFailed:
            navigateToLogin()
        case .vpnNewSelection:
            presentVPNLocationSelection()
        }
    }

    private func navigateToHomeVPN() {
        currentViewController = GuardianTabBarController(viewControllers: tabBarViewControllers)
        setKeyWindow(with: currentViewController!)
    }

    private func navigateToLogin() {
        currentViewController = LoginViewController(accountManager: dependencyProvider.accountManager, coordinatorDelegate: self)
        setKeyWindow(with: currentViewController!)
    }

    private func presentVPNLocationSelection() {
        let locationVPNVC = LocationVPNViewController(accountManager: dependencyProvider.accountManager)
        let navController = UINavigationController(rootViewController: locationVPNVC)
        navController.navigationBar.barTintColor = UIColor.backgroundOffWhite
        navController.navigationBar.tintColor = UIColor.guardianBlack
        currentViewController?.present(navController, animated: true, completion: nil)
    }

    private var tabBarViewControllers: [UIViewController] {
        let homeViewController = HomeVPNViewController(accountManager: dependencyProvider.accountManager, coordinatorDelegate: self)
        return [homeViewController]
    }

    private func setKeyWindow(with viewController: UIViewController) {
        if let window = UIApplication.shared.keyWindow {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
