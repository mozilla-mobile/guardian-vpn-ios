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
    private let headerName = String(describing: DeviceLimitReachedView.self)
    private let cellName = String(describing: DeviceManagementCell.self)
    private var account: Account? { return DependencyFactory.sharedFactory.accountManager.account }
    private let viewModel: DeviceManagementViewModel

    // MARK: Initialization
    init(with tableView: UITableView, viewModel: DeviceManagementViewModel) {
        self.viewModel = viewModel
        super.init()
        tableView.delegate = self
        tableView.dataSource = self

        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: headerName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.deviceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellName,
                                                     for: indexPath) as? DeviceManagementCell,
            // prevents crash if the device list changes and the tableview hasn't reloaded
            indexPath.row < viewModel.deviceList.count
            else { return UITableViewCell(frame: .zero) }

        cell.setup(with: viewModel.deviceList[indexPath.row], event: viewModel.trashTappedSubject)

        return cell
    }
}

// MARK: UITableViewDelegate
extension DeviceManagementDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let account = account, !account.hasDeviceBeenAdded else { return 0 }

        return DeviceLimitReachedView.height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let account = account, !account.hasDeviceBeenAdded else { return nil }

        return tableView.dequeueReusableHeaderFooterView(withIdentifier: headerName)
    }
}
