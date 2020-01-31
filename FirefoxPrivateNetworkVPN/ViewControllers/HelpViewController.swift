//
//  HelpViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class HelpViewController: UIViewController, Navigating {
    // MARK: Properties
    static var navigableItem: NavigableItem = .help

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: HelpDataSource?

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()

        dataSource = HelpDataSource(with: tableView)
        tableView.tableFooterView = UIView()
    }

    // MARK: Setup
    func setupNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil // enables back swipe

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = LocalizedString.helpTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey50)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_backChevron"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
    }

    @objc func goBack() {
        navigate(to: .settings)
    }
}
