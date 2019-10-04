// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import WebKit
import SafariServices

class LoginViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet var webView: WKWebView!

    weak var coordinatorDelegate: NavigationProtocol?

    let userManager = UserManager.sharedManager
    let successfulLoginString = "/vpn/client/login/success"

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
            let loginCheckPointModel = userManager.loginCheckPointModel {
            userManager.verify(with: loginCheckPointModel) { [weak self] result in
                switch result {
                case .success(let _):
                    DispatchQueue.main.async {
                        self?.coordinatorDelegate?.navigate(after: .manualLoginSucceeded)
                    }
                case .failure(let error):
                    print(error) // handle this!
                }
            }
        }
    }
}
