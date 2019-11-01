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
        let count = devices != nil ? devices!.count : 0
        let countTitle = "\(count) of 5"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: countTitle, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.tintColor = .guardianGrey
        navigationItem.title = "My devices"
        navigationItem.titleView?.tintColor = .guardianBlack
    }
}
