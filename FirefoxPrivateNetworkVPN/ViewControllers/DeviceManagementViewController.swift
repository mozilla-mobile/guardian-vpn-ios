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
    @IBOutlet weak var warningToastView: WarningToastView!

    private var dataSource: DeviceManagementDataSource?
    private var account: Account? { return DependencyFactory.sharedFactory.accountManager.account }
    private let disposeBag = DisposeBag()

    private var formattedDeviceCountTitle: String {
        guard let user = account?.user else { return "" }
        let currentDevices = dataSource?.deviceCount ?? 0
        return String(format: LocalizedString.devicesCount.value, "\(currentDevices)", "\(user.maxDevices)")
    }

    private lazy var backButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "icon_backChevron"),
                               style: .plain,
                               target: self,
                               action: #selector(goBack))
    }()

    private lazy var deviceCountItem: UIBarButtonItem = {
        let deviceCountItem = UIBarButtonItem(title: formattedDeviceCountTitle,
                                              style: .plain,
                                              target: nil,
                                              action: nil)

        deviceCountItem.isEnabled = false
        deviceCountItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.custom(.inter), NSAttributedString.Key.foregroundColor: UIColor.custom(.grey40)],
            for: .disabled)

        return deviceCountItem
    }()

    // MARK: View Lifecycle
    //swiftlint:disable trailing_closure
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = DeviceManagementDataSource(with: tableView)
        tableView.tableFooterView = UIView()

        dataSource?
            .removeDeviceEvent
            .subscribe(onNext: { [weak self] device in
                guard let self = self, let account = self.account else { return }

                let confirmAlert = DependencyFactory
                    .sharedFactory
                    .navigationCoordinator
                    .createDeviceDeletionAlert(deviceName: device.name) { _ in
                        account.removeDevice(with: device.publicKey) { result in
                            switch result {
                            case .success:
                                if !account.hasDeviceBeenAdded {
                                    self.addCurrentDeviceToAccount()
                                } else {
                                    self.navigationItem.rightBarButtonItem?.title = self.formattedDeviceCountTitle
                                    self.tableView?.reloadData()
                                }

                            case .failure:
                                self.tableView?.reloadData()
                                self.warningToastView.show(message: NSAttributedString.formattedError(.couldNotRemoveDevice)) {
                                    self.dataSource?.removeDeviceEvent.onNext(device)
                                }
                            }
                        }
                        self.tableView?.reloadData()
                }
                self.present(confirmAlert, animated: true, completion: nil)
            }).disposed(by: disposeBag)

        //refresh device list only if device has already been added to make sure current device gets added
        if let account = account, account.hasDeviceBeenAdded {
            account.getUser { [weak self] result in
                if case .success = result {
                    self?.tableView.reloadData()
                    self?.navigationItem.rightBarButtonItem?.title = self?.formattedDeviceCountTitle
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // MARK: Setup
    private func setupNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil // enables back swipe

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = deviceCountItem

        navigationItem.title = LocalizedString.devicesNavTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey40)

        navigationItem.leftBarButtonItem = backButtonItem
    }

    @objc func goBack() {
        navigate(to: .settings)
    }

    private func addCurrentDeviceToAccount() {
        guard let account = account else {
            tableView?.reloadData()
            return
        }
        account.addCurrentDevice { [weak self] addDeviceResult in
            if case .success = addDeviceResult {
                DependencyFactory.sharedFactory.navigationCoordinator.homeTab(isEnabled: true)
            }
            self?.navigationItem.rightBarButtonItem?.title = self?.formattedDeviceCountTitle
            self?.tableView?.reloadData()
        }
    }
}
