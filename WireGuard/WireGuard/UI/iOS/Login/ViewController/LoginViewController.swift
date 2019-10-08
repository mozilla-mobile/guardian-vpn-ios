// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import WebKit
import SafariServices

class LoginViewController: UIViewController, WKNavigationDelegate {
    let successfulLoginString = "/vpn/client/login/success"

    @IBOutlet var webView: WKWebView!
    private weak var coordinatorDelegate: Navigating?
    private let userManager: UserManaging

    init(userManager: UserManaging, coordinatorDelegate: Navigating) {
        self.userManager = userManager
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: String(describing: LoginViewController.self), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        userManager.retrieveUserLoginInformation { [weak self] result in
            switch result {
            case .success(let checkPointModel):
                DispatchQueue.main.async {
                    let urlRequest = URLRequest(url: checkPointModel.loginUrl)
                    self?.webView.load(urlRequest)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let urlContainsSuccess = webView.url?.absoluteString.contains(successfulLoginString) ?? false
        if urlContainsSuccess,
            userManager.loginCheckPointModel != nil {
            userManager.verifyAfterLogin { [weak self] result in
                switch result {
                case .success:
                    self?.userManager.addDevice { _ in } // TODO: Delete
                    DispatchQueue.main.async {
                        self?.coordinatorDelegate?.navigate(after: .loginSucceeded)
                    }
                case .failure(let error):
                    print(error) // handle this!
                }
            }
        }
    }
}
