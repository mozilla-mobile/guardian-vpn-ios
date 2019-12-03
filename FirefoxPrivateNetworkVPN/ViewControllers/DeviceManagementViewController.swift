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
                            guard !account.hasDeviceBeenAdded else {
                                self.tableView?.reloadData()
                                return
                            }
                            self.addCurrentDeviceToAccount()

                            case .failure:
                                self.tableView?.reloadData()
                                self.warningToastView.show(message: self.formatErrorMessage(with: .couldNotRemoveDevice)) { [weak self] in
                                    self?.dataSource?.removeDeviceEvent.onNext(device)
                                }
                            }
                        }
                        self.tableView?.reloadData()
                }
                self.present(confirmAlert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }

    private func formatErrorMessage(with error: GuardianError) -> NSMutableAttributedString {
        let message = NSMutableAttributedString(string: error.description)
        let actionMessage = NSAttributedString(string: LocalizedString.toastTryAgain.value, attributes: [
            .font: UIFont.custom(.interSemiBold, size: 13),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        message.append(NSAttributedString(string: " "))
        message.append(actionMessage)
        return message
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // MARK: Setup
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: formattedDeviceCountTitle, style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.tintColor = UIColor.custom(.grey50)

        navigationItem.title = LocalizedString.devicesNavTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey40)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_backChevron"), style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
    }

    @objc func goBack() {
        navigate(to: .settings)
    }

    private func addCurrentDeviceToAccount() {
        guard let account = account else { return }
        account.addCurrentDevice { [weak self] addDeviceResult in
            if case .success = addDeviceResult {
                DependencyFactory.sharedFactory.navigationCoordinator.homeTab(isEnabled: true)
            }
            self?.navigationItem.rightBarButtonItem?.title = self?.formattedDeviceCountTitle
            self?.tableView?.reloadData()
        }
    }
}
