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

    private var safariViewController: SFSafariViewController?
    private var verificationURL: URL?
    private var verifyTimer: Timer?
    private var isVerifying = false

    init() {
        super.init(nibName: nil, bundle: nil)
        GuardianAPI.initiateUserLogin { [weak self] result in
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
            case .failure:
                self?.navigate(to: .landing)
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
        GuardianAPI.verify(urlString: verificationURL.absoluteString) { [unowned self] result in
            self.isVerifying = false
            DispatchQueue.main.async {
                switch result {
                case .success(let verification):
                    self.verifyTimer?.invalidate()
                    let account = Account(with: verification)
                    account.setupFromVerification { finishResult in
                        DispatchQueue.main.async {
                            switch finishResult {
                            case .success:
                                DependencyFactory.sharedFactory.set(account: account)
                                self.navigate(to: .home)
                            case .failure:
                                self.navigate(to: .landing)
                            }
                        }
                    }
                case .failure:
                    return
                }
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
        navigate(to: .landing)
    }
}
