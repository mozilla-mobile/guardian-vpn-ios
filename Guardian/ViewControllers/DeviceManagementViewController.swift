// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class DeviceManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: DeviceDataSourceAndDelegate?
    private var devices: [Device]?

    init(devices: [Device]) {
        self.devices = devices
        super.init(nibName: String(describing: DeviceManagementViewController.self), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let devices = devices else { return }
        dataSource = DeviceDataSourceAndDelegate(devices: devices, tableView: tableView)
        tableView.tableFooterView = UIView()
        setupNavigationBar()
    }

    func setupNavigationBar() {
        // TODO: Set up the navigation on this screen
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
    }
}
