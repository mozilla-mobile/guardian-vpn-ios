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
    var removeDeviceEvent = PublishSubject<Device>()

    private let headerName = String(describing: DeviceLimitReachedView.self)
    private let cellName = String(describing: DeviceManagementCell.self)
    private var account: Account? { return DependencyFactory.sharedFactory.accountManager.account }

    private var representedObject: [Device] {
        guard let account = account else { return [] }

        var devices = account.user?.deviceList
        if account.isOverDeviceLimit {
            devices?.insert(Device.mock(name: UIDevice.current.name), at: 0)
        }
        return devices ?? []
    }

    var deviceCount: Int {
        representedObject.count
    }

    // MARK: Initialization
    init(with tableView: UITableView) {
        super.init()
        tableView.delegate = self
        tableView.dataSource = self

        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: headerName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)

        //refresh device list only if device has already been added to make sure current device gets added
        if let account = account, account.hasDeviceBeenAdded {
            account.getUser { _ in }
        }
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
        guard let account = account, account.isOverDeviceLimit else { return 0 }

        return DeviceLimitReachedView.height

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let account = account, account.isOverDeviceLimit else { return nil }

        return tableView.dequeueReusableHeaderFooterView(withIdentifier: headerName)
    }
}
