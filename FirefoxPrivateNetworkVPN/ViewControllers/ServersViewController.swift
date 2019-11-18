//
//  ServersViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import RxSwift

class ServersViewController: UIViewController, Navigating {
    // MARK: - Properties
    static var navigableItem: NavigableItem = .servers

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: ServersDataSource?
    private var disposeBag = DisposeBag()

    // MARK: - Initialization
    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
        DependencyFactory.sharedFactory.tunnelManager.cityChangedEvent
            .subscribe { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        tableView.contentInsetAdjustmentBehavior = .never
        dataSource = ServersDataSource(with: tableView)
        tableView.reloadData()
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
        navigationItem.title = LocalizedString.serversNavTitle.value
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Metropolis", size: 15)!]
        // TODO: navigationItem. FONT: Metro semibold 15
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
