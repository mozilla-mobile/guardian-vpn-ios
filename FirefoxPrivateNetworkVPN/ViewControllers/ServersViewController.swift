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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = dataSource?.selectedIndexPath {
            tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
        }
    }

    // MARK: - Setup
    private func setupNavigationBar() {
//        let leftSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        leftSpacer.width = 0.5
        let closeButton = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItems = [closeButton]
        navigationItem.title = LocalizedString.serversNavTitle.value
        navigationController?.navigationBar.setTitleFont()
        navigationController?.navigationBar.barTintColor = UIColor.custom(.grey5)
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
