// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    let accountManager: AccountManaging
    weak var coordinatorDelegate: Navigating?

    init(accountManager: AccountManaging, coordinatorDelegate: Navigating) {
        self.accountManager = accountManager
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: String(describing: LoadingViewController.self), bundle: Bundle.main)
        self.accountManager.setupFromAppLaunch { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.coordinatorDelegate?.navigate(after: .loginSucceeded)
                case .failure:
                    self?.coordinatorDelegate?.navigate(after: .loginFailed)
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
