//
//  NavigationCoordinator
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import os.log

enum NavigableItem: Hashable {
    case about
    case carousel
    case devices
    case help
    case home
    case landing
    case loading
    case login
    case product
    case servers
    case settings
    case tab
    case account
    case appStore
    case recommendedUpdate
    case requiredUpdate
    case safari
}

enum NavigableContext {
    case maxDevicesReached
    case url(URL?)
    case error(LocalizedError)
}

class NavigationCoordinator: NavigationCoordinating {

    private var currentViewController: (UIViewController & Navigating)?
    private weak var appDelegate = UIApplication.shared.delegate as? AppDelegate

    var firstViewController: UIViewController {
        let loadingViewController = LoadingViewController()
        currentViewController = loadingViewController
        return loadingViewController
    }

    func navigate(from origin: NavigableItem, to destination: NavigableItem, context: NavigableContext?) {
        OSLog.logUI(.info, "Navigating from %@ to %@.", args: "\(origin)", "\(destination)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch (origin, destination) {
            // To Landing
            case (.loading, .landing):
                self.initializeWithLandingScreen()

            case (.settings, .landing), (.account, .landing), (.requiredUpdate, .landing):
                self.initializeWithLandingScreen()

                if let landingViewController = self.currentViewController as? LandingViewController {
                    landingViewController.showSuccessfulLogoutToast()
                }

            case (.login, .landing):
                self.currentViewController?.presentedViewController?.dismiss(animated: true, completion: nil)

                switch context {
                case .maxDevicesReached:
                    self.navigate(from: .landing, to: .home, context: .maxDevicesReached)
                    return
                case .error(let error):
                    if let landingViewController = self.currentViewController as? LandingViewController {
                        landingViewController.showToast(with: error)
                    }
                    return
                default: return
                }

            // To Home
            case (.loading, .home), (.landing, .home), (.login, .home):
                let tabBarController = GuardianTabBarController()
                tabBarController.displayTab(.home)
                self.appDelegate?.window?.rootViewController = tabBarController
                self.currentViewController = tabBarController

                if case .maxDevicesReached = context {
                    self.navigate(from: .home, to: .settings)
                    self.navigate(from: .settings, to: .devices, context: .maxDevicesReached)
                }

            // To Home
            case (.settings, .home), (.tab, .home):
                (self.currentViewController as? GuardianTabBarController)?.displayTab(.home)

            // To Product
            case (.home, .product), (.settings, .product):
                let productViewController = ProductViewController()
                let navController = UINavigationController(rootViewController: productViewController)
                self.currentViewController?.present(navController, animated: true, completion: nil)

            // To Servers
            case (.home, .servers):
                let serversViewController = ServersViewController()
                let navController = UINavigationController(rootViewController: serversViewController)
                self.currentViewController?.present(navController, animated: true, completion: nil)

            case (.servers, .home):
                self.currentViewController?.dismiss(animated: true, completion: nil)

            // To Settings
            case (.home, .settings), (.tab, .settings):
                (self.currentViewController as? GuardianTabBarController)?.displayTab(.settings)

            case (.devices, .settings), (.about, .settings), (.help, .settings):
                let navController = (self.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.popViewController(animated: true)

            // To Login
            case (.landing, .login):
                let loginViewController = LoginViewController()
                loginViewController.modalPresentationStyle = .fullScreen
                self.currentViewController?.present(loginViewController, animated: true, completion: nil)

            case (.carousel, .login):
                self.currentViewController?.presentedViewController?.dismiss(animated: true) {
                    self.navigate(from: .landing, to: .login)
                }

            // To Onboarding carousel
            case (.landing, .carousel):
                let carouselPageViewController = CarouselPageViewController()
                self.currentViewController?.present(UINavigationController(rootViewController: carouselPageViewController), animated: true, completion: nil)
                if #available(iOS 13.0, *) {
                    self.currentViewController?.view.alpha = 0.5
                }

            case (.carousel, .landing):
                self.currentViewController?.presentedViewController?.dismiss(animated: true, completion: nil)

            // To Devices
            case (.settings, .devices):
                let devicesViewController = DeviceManagementViewController()
                let navController = (self.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.pushViewController(devicesViewController, animated: true)

                if case .maxDevicesReached = context {
                    self.homeTab(isEnabled: false)
                }

            // To Help
            case (.settings, .help):
                let helpViewController = HelpViewController()
                let navController = (self.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.pushViewController(helpViewController, animated: true)

            // To About
            case (.settings, .about):
                let aboutViewController = AboutViewController()
                let navController = (self.currentViewController as? GuardianTabBarController)?.tab(.settings) as? UINavigationController
                navController?.pushViewController(aboutViewController, animated: true)

            case (_, .safari):
                if case .url(let value) = context,
                    let url = value {
                    UIApplication.shared.open(url)
                }

            case (_, .appStore):
                UIApplication.shared.openAppStore()

            case (.home, .requiredUpdate):
                let updateRequiredViewController = UpdateRequiredViewController()
                self.appDelegate?.window?.rootViewController = updateRequiredViewController
                self.currentViewController = updateRequiredViewController

            default: // You can't get there from here.
                Logger.global?.log(message: "Navigation is unhandled: From: \(origin), To: \(destination)")
                return
            }
        }
    }

    func homeTab(isEnabled: Bool) {
        if let tabBarController = self.currentViewController as? GuardianTabBarController {
            tabBarController.tabBar.items?[0].isEnabled = isEnabled
        }
    }

    func createDeviceDeletionAlert(deviceName: String, handler: DeletionConfirmedHandler?) -> UIAlertController {
        let alert = UIAlertController(title: LocalizedString.devicesConfirmDeletionTitle.value,
            message: String(format: LocalizedString.devicesConfirmDeletionMessage.value, deviceName),
            preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: LocalizedString.devicesCancelDeletion.value,
            style: .default) { _ in /* Do nothing */ })
        alert.addAction(UIAlertAction(title: LocalizedString.devicesConfirmDeletion.value,
          style: .destructive,
          handler: handler))

        return alert
    }

    private func initializeWithLandingScreen() {
        let landingViewController = LandingViewController()
        self.appDelegate?.window?.rootViewController = landingViewController
        self.currentViewController = landingViewController
    }
}
