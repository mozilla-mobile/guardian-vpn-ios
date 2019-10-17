// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import SafariServices

class LoginWebViewController: UIViewController, SFSafariViewControllerDelegate {
    private let successfulLoginString = "/vpn/client/login/success"
    private let accountManager: AccountManaging
    private weak var navigatingDelegate: Navigating?

    private var safariViewController: SFSafariViewController?
    private var verificationUrl: URL?

    init(accountManager: AccountManaging, navigatingDelegate: Navigating) {
        self.accountManager = accountManager
        self.navigatingDelegate = navigatingDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        accountManager.login { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let checkPointModel):
                DispatchQueue.main.async {
                    self.verificationUrl = checkPointModel.verificationUrl

                    let safariVc = SFSafariViewController(url: checkPointModel.loginUrl)
                    self.addChild(safariVc)
                    self.view.addSubview(safariVc.view)
                    safariVc.view.frame = self.view.bounds
                    safariVc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    safariVc.didMove(toParent: self)
                    safariVc.delegate = self
                    self.safariViewController = safariVc
                }
            case .failure(let error):
                // TODO: Handle failure here
                print("Failure: Could not retrieve login page")
                print(error)
            }
        }
    }

    // MARK: SFSafariViewControllerDelegate
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        guard let verificationUrl = verificationUrl else { return }

        if URL.absoluteString.contains(successfulLoginString) {
            accountManager.setupFromVerify(url: verificationUrl) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.navigatingDelegate?.navigate(after: .loginSucceeded)
                case .failure(let error):
                    self.navigatingDelegate?.navigate(after: .loginFailed)
                    print("Failure: Could not verify login page")
                    print(error)
                }
            }
        }
    }
}
