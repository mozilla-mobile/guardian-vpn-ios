//
//  LoginViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import SafariServices

extension Notification.Name {
    static let callbackURLNotification = Notification.Name("callbackURL")
}

class LoginViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .login

    private let guardianAPI = DependencyManager.shared.guardianAPI
    private var safariViewController: SFSafariViewController?
    private let accountManager = DependencyManager.shared.accountManager
    private let PKCECode: (String, String) = PKCECodeGenerator.generateCode

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let safariViewController = SFSafariViewController(url: GuardianURLRequest.pkceLoginURL(codeChallenge: PKCECode.0))
        addChild(safariViewController)
        view.addSubview(safariViewController.view)
        safariViewController.view.frame = self.view.bounds
        safariViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        safariViewController.didMove(toParent: self)
        safariViewController.delegate = self
        self.safariViewController = safariViewController

        NotificationCenter.default.addObserver(self, selector: #selector(handleCallback), name: .callbackURLNotification, object: nil)
    }

    @objc private func handleCallback(notification: Notification) {
        guard let url = notification.userInfo?["callbackURL"] as? URL,
            let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
            let code = queryItems.first(where: { $0.name == "code" })?.value else {
            navigate(to: .landing)
            return
        }
        verify(code: code)
    }

    private func verify(code: String) {
        guardianAPI.verify(code: code, codeVerifier: PKCECode.1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let verification):
                self.login(verification: verification)
            case .failure(let error):
                self.navigate(to: .landing, context: .error(error))
            }
        }
    }

    private func login(verification: VerifyResponse) {
        accountManager.login(with: verification) { [weak self] loginResult in
            guard let self = self else { return }
            switch loginResult {
            case .success:
                self.navigate(to: .home)
            case .failure(let error):
                Logger.global?.log(message: "Authentication Error: \(error)")
                let context: NavigableContext = error == .maxDevicesReached ? .maxDevicesReached : .error(error)
                self.navigate(to: .landing, context: context)
            }
        }
    }
}

// MARK: - SFSafariViewControllerDelegate
extension LoginViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        navigate(to: .landing)
    }
}
