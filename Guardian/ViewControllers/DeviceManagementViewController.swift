// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class DeviceManagementViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private weak var dataSourceAndDelegate: DeviceDataSourceAndDelegate?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    func setup(dataSourceAndDelegate: DeviceDataSourceAndDelegate) {
        self.dataSourceAndDelegate = dataSourceAndDelegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib.init(nibName: String(describing: DeviceManagementCell.self), bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: String(describing: DeviceManagementCell.self))
        let headerNib = UINib.init(nibName: "DeviceLimitReachedView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "DeviceLimitReachedView")
        tableView.dataSource = dataSourceAndDelegate
        tableView.delegate = dataSourceAndDelegate

        setupNavigationBar()
    }

    func setupNavigationBar() {
        // TODO: Set up the navigation on this screen
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationItem.title = "My devices"
        navigationController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
