//
//  DeviceManagementViewController
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

class DeviceManagementViewController: UIViewController, Navigating {
    // MARK: Properties
    static var navigableItem: NavigableItem = .devices

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: DeviceManagementDataSource?
    private var account: Account? { return DependencyFactory.sharedFactory.accountManager.account }
    private let disposeBag = DisposeBag()

    // MARK: View Lifecycle
    //swiftlint:disable trailing_closure
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = DeviceManagementDataSource(with: tableView)
        tableView.tableFooterView = UIView()

        dataSource?
            .removeDeviceEvent
            .subscribe(onNext: { [weak self] deviceKey in
                guard let account = self?.account else { return }

                let confirmAlert = DependencyFactory
                    .sharedFactory
                    .navigationCoordinator
                    .createDeviceDeletionAlert { _ in
                        account.removeDevice(with: deviceKey) { result in
                            if case .success = result, !account.hasDeviceBeenAdded {
                                account.addCurrentDevice { addDeviceResult in
                                    if case .success = addDeviceResult {
                                        DependencyFactory.sharedFactory.navigationCoordinator.homeTab(isEnabled: true)
                                    }
                                    self?.tableView?.reloadData()
                                }
                            } else {
                                self?.tableView?.reloadData()
                            }
                        }
                        self?.tableView?.reloadData()
                }
                self?.present(confirmAlert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // MARK: Setup
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        guard let user = DependencyFactory.sharedFactory.accountManager.account?.user else { return }
        let countTitle = String(format: LocalizedString.devicesCount.value, "\(dataSource?.deviceCount ?? 0)", "\(user.maxDevices)")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: countTitle, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.custom(.grey50)
        navigationItem.title = LocalizedString.devicesNavTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey40)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_backChevron"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
    }

    @objc func goBack() {
        navigate(to: .settings)
    }
}
