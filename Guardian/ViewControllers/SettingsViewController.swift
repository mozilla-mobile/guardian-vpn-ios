// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class SettingsViewController: UIViewController {
    private let accountManager: AccountManaging
    private let navigationCoordinator: Navigating
    private var dataSource: SettingsDataSourceAndDelegate?

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
        dataSource = SettingsDataSourceAndDelegate(tableView: tableView, navigationCoordinator: navigationCoordinator)
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func signOut(_ sender: Any) {
        accountManager.logout { [weak self] result in
            DependencyFactory.sharedFactory.tunnelManager.signOut()
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.navigationCoordinator.navigate.onNext(.logout)
                case .failure(let error):
                    self.navigationCoordinator.navigate.onNext(.logoutFailed)
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
