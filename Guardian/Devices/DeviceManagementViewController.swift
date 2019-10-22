// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class DeviceManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let dataSourceAndDelegate: DeviceDataSourceAndDelegate

    init(dataSourceAndDelegate: DeviceDataSourceAndDelegate) {
        self.dataSourceAndDelegate = dataSourceAndDelegate
        super.init(nibName: String(describing: DeviceManagementViewController.self), bundle: Bundle.main)

        let nib = UINib.init(nibName: String(describing: DeviceManagementCell.self), bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: String(describing: DeviceManagementCell.self))
        let headerNib = UINib.init(nibName: "DeviceLimitReachedView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "DeviceLimitReachedView")
        tableView.dataSource = dataSourceAndDelegate
        tableView.delegate = dataSourceAndDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    func setupNavigationBar() {
        navigationItem.title = "My devices"
    }
}
