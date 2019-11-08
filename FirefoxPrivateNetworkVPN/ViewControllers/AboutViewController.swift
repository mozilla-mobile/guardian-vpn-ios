//
//  AboutViewController
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .devices

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: AboutDataSourceAndDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()

        dataSource = AboutDataSourceAndDelegate(tableView: tableView)
        tableView.tableFooterView = UIView()
    }

    @objc func goBack() {
        navigate(to: .settings)
    }

    func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = LocalizedString.aboutTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey50)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_backChevron"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
    }
}
