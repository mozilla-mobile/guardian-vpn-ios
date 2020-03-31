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

class LoginViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .login

    private let guardianAPI = DependencyManager.shared.guardianAPI
    private var safariViewController: SFSafariViewController?
    private var verificationURL: URL?
    private var verifyTimer: Timer?
    private var isVerifying = false

    init() {
        super.init(nibName: nil, bundle: nil)
        guardianAPI.initiateUserLogin { [weak self] result in
            switch result {
            case .success(let checkpointModel):
                guard let loginURL = checkpointModel.loginUrl else { return }
                self?.verificationURL = checkpointModel.verificationUrl
                let safariViewController = SFSafariViewController(url: loginURL)
                DispatchQueue.main.async {
                    self?.addChild(safariViewController)
                    self?.view.addSubview(safariViewController.view)
                    safariViewController.view.frame = self?.view.bounds ?? CGRect.zero
                    safariViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    safariViewController.didMove(toParent: self)
                }
                safariViewController.delegate = self
                self?.safariViewController = safariViewController
            case .failure(let error):
                let loginError = error.getLoginError()
                let context: NavigableContext = loginError == .maxDevicesReached ? .maxDevicesReached : .error(loginError)
                self?.navigate(to: .landing, context: context)
            }
        }
    }

    deinit {
        verifyTimer?.invalidate()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func verify() {
        guard let verificationURL = verificationURL else { return }
        if isVerifying { return }
        isVerifying = true

        guardianAPI.verify(urlString: verificationURL.absoluteString) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let verification):
                DependencyManager.shared.accountManager.login(with: verification) { loginResult in
                    self.isVerifying = false
                    self.verifyTimer?.invalidate()
                    switch loginResult {
                    case .success:
                        self.navigate(to: .home)
                    case .failure(let error):
                        Logger.global?.log(message: "Authentication Error: \(error)")
                        self.navigate(to: .landing, context: .error(error))
                    }
                }
            case .failure:
                self.isVerifying = false
                return
            }
        }
    }
}

// MARK: - SFSafariViewControllerDelegate
extension LoginViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if didLoadSuccessfully && verifyTimer == nil {
            verifyTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(verify), userInfo: nil, repeats: true)
        }
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.verifyTimer?.invalidate()
        navigate(to: .landing)
    }
}
