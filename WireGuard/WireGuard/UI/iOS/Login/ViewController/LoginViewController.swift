// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import WebKit
import SafariServices

class LoginViewController: UIViewController, WKNavigationDelegate {
    let successfulLoginString = "/vpn/client/login/success"

    @IBOutlet var webView: WKWebView!
    private weak var coordinatorDelegate: Navigating?
    private let accountManager: AccountManaging
    private var verificationURL: URL?

    init(accountManager: AccountManaging, coordinatorDelegate: Navigating) {
        self.accountManager = accountManager
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: String(describing: LoginViewController.self), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        accountManager.login { [weak self] result in
            switch result {
            case .success(let checkPointModel):
                DispatchQueue.main.async {
                    self?.verificationURL = checkPointModel.verificationUrl
                    let urlRequest = URLRequest(url: checkPointModel.loginUrl)
                    self?.webView.load(urlRequest)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let urlString = webView.url?.absoluteString, urlString.contains(successfulLoginString) {
            setupAccount { [weak self] result in
                DispatchQueue.main.async {
                    if case .failure(let error) = result {
                        self?.coordinatorDelegate?.navigate(after: .loginFailed)
                        print(error) //handle this
                        return
                    }
                    self?.accountManager.retrieveVPNServers { _ in }
                    self?.coordinatorDelegate?.navigate(after: .loginSucceeded)
                }
            }
        }
    }

    private func setupAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let verificationURL = verificationURL else {
            completion(.failure(GuardianFailReason.loginError))
            return
        }
        accountManager.verify(url: verificationURL) { [weak self] result in
            do {
                let verification = try result.get()
                self?.accountManager.set(with: Account.init(user: verification.user, token: verification.token))
                self?.accountManager.addDevice { deviceResult in
                    switch deviceResult {
                    case .success(let device):
                        completion(.success(()))
                    case .failure(let deviceError):
                        completion(.failure(deviceError))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
