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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)

        var deviceCountLabel = ""
        if let count = devices?.count {
            deviceCountLabel = "\(count) of 5"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: deviceCountLabel, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.047, green: 0.047, blue: 0.051, alpha: 0.6)
        navigationItem.title = "My devices"
        navigationItem.titleView?.tintColor = UIColor(red: 0.047, green: 0.047, blue: 0.051, alpha: 0.8)
    }
}
