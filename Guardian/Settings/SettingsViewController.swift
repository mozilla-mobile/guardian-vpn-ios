// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class SettingsViewController: UIViewController {
    private let accountManager: AccountManaging
    private let navigationCoordinator: Navigating

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var signOutButton: UIButton!

    init(accountManager: AccountManaging, navigationCoordinator: Navigating) {
        self.accountManager = accountManager
        self.navigationCoordinator = navigationCoordinator
        super.init(nibName: String(describing: SettingsViewController.self), bundle: Bundle.main)

        setupTabBar()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signOut(_ sender: Any) {
        accountManager.logout { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.navigationCoordinator.navigate(after: .logout)
                case .failure(let error):
                    self.navigationCoordinator.navigate(after: .loginFailed)
                    print(error)
                }
            }
        }
    }

    private func setupTabBar() {
        tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings"), tag: 1)
        tabBarController?.selectedIndex = 1
    }
}
