// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let accountManager: AccountManaging
    weak var coordinatorDelegate: Navigating?

    init(accountManager: AccountManaging, coordinatorDelegate: Navigating) {
        self.accountManager = accountManager
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: String(describing: LoadingViewController.self), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            coordinatorDelegate?.navigate(after: .loginFailed)
            return
        }
        accountManager.retrieveUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.accountManager.set(with: Account(user: user,
                                                 token: token,
                                                 device: Device.fetchFromUserDefaults())) { setAccountResult in
                                                    DispatchQueue.main.async {
                                                        switch setAccountResult {
                                                        case .success:
                                                            self?.coordinatorDelegate?.navigate(after: .loginSucceeded)
                                                        case .failure(let error):
                                                            //display error?
                                                            print(error)
                                                            self?.coordinatorDelegate?.navigate(after: .loginFailed)
                                                        }
                                                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self?.coordinatorDelegate?.navigate(after: .loginFailed)
                }
            }
        }
    }
}
