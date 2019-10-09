// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    let userManager: AccountManaging
    weak var coordinatorDelegate: Navigating?

    init(userManager: AccountManaging, coordinatorDelegate: Navigating) {
        self.userManager = userManager
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: String(describing: LoadingViewController.self), bundle: Bundle.main)

        userManager.accountInfo { [weak self] result in
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
