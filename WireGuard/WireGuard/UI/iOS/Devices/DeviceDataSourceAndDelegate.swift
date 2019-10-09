// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class DeviceDataSourceAndDelegate: NSObject {
    private var devices: [Device]

    private var canAddDevice: Bool {
        return devices.count < 5
    }

    private var sectionHeight: CGFloat {
        return canAddDevice ? 0 : DeviceLimitReachedView.height
    }

    init(devices: [Device]) {
        self.devices = devices
        super.init()
    }
}

extension DeviceDataSourceAndDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard canAddDevice else {
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: DeviceLimitReachedView.self))
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }
}

extension DeviceDataSourceAndDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DeviceManagementCell.self), for: indexPath) as? DeviceManagementCell else {
            return UITableViewCell(frame: .zero)
        }
        cell.nameLabel.text = devices[indexPath.row].name

        return cell
    }
}
