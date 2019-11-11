//
//  DeviceManagementViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class DeviceManagementViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .devices

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: DeviceDataSourceAndDelegate?

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = DeviceDataSourceAndDelegate(tableView: tableView)
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    @objc func goBack() {
        navigate(to: .settings)
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        guard let user = DependencyFactory.sharedFactory.accountManager.user else { return }
        let countTitle = String(format: LocalizedString.devicesCount.value, "\(user.deviceList.count)", "\(user.maxDevices)")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: countTitle, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.custom(.grey50)
        navigationItem.title = LocalizedString.devicesNavTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey40)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_backChevron"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
    }
}
