//
//  DeviceManagementViewController
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

class DeviceManagementViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .devices

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: DeviceDataSourceAndDelegate?
    private var devices: [Device]?

    init(devices: [Device]) {
        self.devices = devices
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

    func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let count = devices != nil ? devices!.count : 0

        // TODO: Get max allowed devices from account.
        let countTitle = String(format: LocalizedString.devicesCount.value, "\(count)", "5")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: countTitle, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.custom(.grey40)
        navigationItem.title = LocalizedString.devicesNavTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey40)
    }
}
