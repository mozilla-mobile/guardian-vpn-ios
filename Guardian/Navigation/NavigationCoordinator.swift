// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import RxSwift

class NavigationCoordinator: Navigating {
    let dependencyProvider: DependencyProviding
    var currentViewController: UIViewController?

    var navigate = PublishSubject<NavigationAction>()

    private let disposeBag = DisposeBag()

    init(dependencyProvider: DependencyProviding) {
        self.dependencyProvider = dependencyProvider
        setupHeartbeat()
        setupServerList()
        setupNavigationActions()
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

    private func setupNavigationActions() {
        navigate
            .subscribe { [weak self] navActionEvent in
                guard let navAction = navActionEvent.element else { return }
                self?.navigate(after: navAction)
        }.disposed(by: disposeBag)
    }

    // MARK: <NavigationProtocol>
    private func navigate(after action: NavigationAction) {
        switch action {
        case .loading, .logout, .logoutFailed:
            navigateToLandingScreen()
        case .loginSucceeded:
            navigateToHomeVPN()
        case .loginFailed:
            navigateToLogin()
        case .vpnNewSelection:
            presentVPNLocationSelection()
        case .devicesSelection:
            navigateToDeviceManagement()
        case .aboutSelection:
            break
        case .helpSelection:
            break
        }
    }

    private func navigateToLandingScreen() {
        let currentViewController = LandingViewController(coordinatorDelegate: self)
        self.currentViewController = currentViewController
        DispatchQueue.main.async { [weak self] in
            self?.setKeyWindow(with: currentViewController)
        }
    }

    private func navigateToHomeVPN() {
        let currentViewController = GuardianTabBarController(viewControllers: tabBarViewControllers)
        self.currentViewController = currentViewController
        DispatchQueue.main.async { [weak self] in
            self?.setKeyWindow(with: currentViewController)
        }
    }

    private func navigateToLogin() {
        let currentViewController = LoginViewController(accountManager: dependencyProvider.accountManager, navigatingDelegate: self)
        self.currentViewController = currentViewController
        DispatchQueue.main.async { [weak self] in
            self?.setKeyWindow(with: currentViewController)
        }
    }

    private func navigateToDeviceManagement() {
        guard let user = dependencyProvider.accountManager.user else { return }
        let deviceManagementVC = DeviceManagementViewController(devices: user.devices)

        if let navigationController = currentViewController?.children[1] as? UINavigationController {
            navigationController.pushViewController(deviceManagementVC, animated: true)
        }
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

        let navigationViewController = UINavigationController(rootViewController: settingsViewController)

        return [homeViewController, navigationViewController]
    }

    private func setKeyWindow(with viewController: UIViewController) {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }
}
