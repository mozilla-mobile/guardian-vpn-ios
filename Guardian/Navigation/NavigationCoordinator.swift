// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import RxSwift

class NavigationCoordinator: Navigating {
    let dependencyProvider: DependencyProviding
    var currentViewController: UIViewController?

    private let disposeBag = DisposeBag()

    init(dependencyProvider: DependencyProviding) {
        self.dependencyProvider = dependencyProvider
        setupHeartbeat()
        setupServerList()
    }

    var rootViewController: UIViewController {
        let accountManager = dependencyProvider.accountManager
        let loadingViewController = LoadingViewController(accountManager: accountManager, coordinatorDelegate: self)
        currentViewController = loadingViewController
        return loadingViewController
    }

    private func setupHeartbeat() {
        dependencyProvider.accountManager.heartbeatFailedEvent
            .subscribe { [weak self] _ in
                self?.navigateToLogin()
        }.disposed(by: disposeBag)
        dependencyProvider.accountManager.startHeartbeat() // TODO: Should this be here?
    }

    private func setupServerList() {
        dependencyProvider.tunnelManager.cityChangedEvent
            .subscribe { [weak self] _ in
                self?.currentViewController?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }

    // MARK: <NavigationProtocol>
    internal func navigate(after action: NavigationAction) {
        switch action {
        case .loginSucceeded:
            navigateToHomeVPN()
        case .loginFailed, .logout:
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
        currentViewController = LoginViewController(accountManager: dependencyProvider.accountManager, navigatingDelegate: self)
        setKeyWindow(with: currentViewController!)
    }

    private func presentVPNLocationSelection() {
        let locationVPNVC = ServersViewController(accountManager: dependencyProvider.accountManager)
        let navController = UINavigationController(rootViewController: locationVPNVC)
        navController.navigationBar.barTintColor = UIColor.backgroundOffWhite
        navController.navigationBar.tintColor = UIColor.guardianBlack
        currentViewController?.present(navController, animated: true, completion: nil)
    }

    private var tabBarViewControllers: [UIViewController] {
        let homeViewController = HomeViewController(
            accountManager: dependencyProvider.accountManager,
            tunnelManager: dependencyProvider.tunnelManager,
            coordinatorDelegate: self)

        let settingsViewController = SettingsViewController(
            accountManager: dependencyProvider.accountManager,
            navigationCoordinator: self)

        return [homeViewController, settingsViewController]
    }

    private func setKeyWindow(with viewController: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
