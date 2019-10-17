// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import WebKit

class LoginViewController: UIViewController, WKNavigationDelegate {
    let successfulLoginString = "/vpn/client/login/success"

    private let accountManager: AccountManaging
    private weak var navigatingDelegate: Navigating?
    private var verificationURL: URL?
    @IBOutlet var webView: WKWebView!

    init(accountManager: AccountManaging, navigatingDelegate: Navigating) {
        self.accountManager = accountManager
        self.navigatingDelegate = navigatingDelegate
        super.init(nibName: String(describing: LoginViewController.self), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        accountManager.login { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let checkPointModel):
                DispatchQueue.main.async {
                    self.verificationURL = checkPointModel.verificationUrl
                    let urlRequest = URLRequest(url: checkPointModel.loginUrl)
                    self.webView.load(urlRequest)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let verificationUrl = verificationURL else { return }
        let isSuccessfulLogin = webView.url?.absoluteString.contains(successfulLoginString) ?? false
        if isSuccessfulLogin {
            accountManager.setupFromVerify(url: verificationUrl) { [unowned self] result in
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
