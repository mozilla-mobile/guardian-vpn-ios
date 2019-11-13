//
//  DeviceManagementDataSource
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
import RxCocoa

class DeviceManagementDataSource: NSObject, UITableViewDataSource {
    // MARK: Properties
    private var representedObject: [Device]
    var removeDeviceEvent = PublishSubject<String>()
    private let disposeBag = DisposeBag()

    private let headerName = String(describing: DeviceLimitReachedView.self)
    private let cellName = String(describing: DeviceManagementCell.self)
    private let account = DependencyFactory.sharedFactory.accountManager.account

    // MARK: Initialization
    init(with tableView: UITableView) {
        representedObject = account?.user?.deviceList ?? []
        super.init()
        tableView.delegate = self
        tableView.dataSource = self

        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: headerName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)

        removeDeviceEvent
            .subscribe { [weak tableView] event in
                guard let deviceKey = event.element else { return }

                guard let account = DependencyFactory.sharedFactory.accountManager.account else { return }
                account.removeDevice(with: deviceKey) { result in
                    DispatchQueue.main.async {
                        guard case .success = result, Device.fetchFromUserDefaults() == nil else {
                            tableView?.reloadData()
                            return
                        }
                        account.addCurrentDevice { addDeviceResult in
                            DispatchQueue.main.async {
                                if case .success = addDeviceResult {
                                    DependencyFactory.sharedFactory.navigationCoordinator.homeTab(isEnabled: true)
                                }
                                tableView?.reloadData()
                            }
                        }
                    }
                }
        }.disposed(by: disposeBag)
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        representedObject.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? DeviceManagementCell
            else { return UITableViewCell(frame: .zero) }
        cell.setup(with: representedObject[indexPath.row], event: removeDeviceEvent)
        return cell
    }
}

// MARK: UITableViewDelegate
extension DeviceManagementDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if account?.user?.hasReachedMaxDevices ?? false {
            return DeviceLimitReachedView.height
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if account?.user?.hasReachedMaxDevices ?? false {
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: headerName)
        } else {
            return nil
        }
    }
}
