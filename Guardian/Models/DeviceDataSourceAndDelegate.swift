// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class DeviceDataSourceAndDelegate: NSObject {
    private var devices: [Device]
    private var tableView: UITableView

    private var canAddDevice: Bool {
        return devices.count < 5
    }

    private var sectionHeight: CGFloat {
        return canAddDevice ? 0 : DeviceLimitReachedView.height
    }

    init(devices: [Device], tableView: UITableView) {
        self.devices = devices
        self.tableView = tableView
        super.init()

        tableView.dataSource = self
        tableView.delegate = self

        let headerNib = UINib.init(nibName: String(describing: DeviceLimitReachedView.self), bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: String(describing: DeviceLimitReachedView.self))

        let nib = UINib.init(nibName: String(describing: DeviceManagementCell.self), bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: String(describing: DeviceManagementCell.self))
    }
}

// MARK: - UITableViewDelegate
extension DeviceDataSourceAndDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return canAddDevice ? nil : tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: DeviceLimitReachedView.self))
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return canAddDevice ? 0 : sectionHeight
    }
}

// MARK: - UITableViewDataSource
extension DeviceDataSourceAndDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DeviceManagementCell.self), for: indexPath) as? DeviceManagementCell else {
            return UITableViewCell(frame: .zero)
        }
        cell.setup(with: devices[indexPath.row])

        return cell
    }
}
