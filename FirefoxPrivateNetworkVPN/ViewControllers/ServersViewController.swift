//
//  ServersViewController
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit
import RxSwift

class ServersViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .servers

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: ServersDataSourceAndDelegate?
    private var disposeBag = DisposeBag()

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)

        DependencyFactory.sharedFactory.tunnelManager.cityChangedEvent.subscribe { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .never
        setupNavigationBar()
        dataSource = ServersDataSourceAndDelegate(tableView: tableView)
        tableView.reloadData()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
        navigationItem.title = LocalizedString.serversNavTitle.value
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
