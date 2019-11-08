//
//  DeviceDataSourceAndDelegate
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DeviceDataSourceAndDelegate: NSObject {
    private var tableView: UITableView
    var removeDeviceEvent = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    private var user: User? { return DependencyFactory.sharedFactory.accountManager.user }
    private var devices: [Device] { return user?.deviceList ?? [] }

    private var headerHeight: CGFloat {
        guard let user = user, user.hasTooManyDevices else { return 0 }
        return DeviceLimitReachedView.height
    }

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()

        tableView.dataSource = self
        tableView.delegate = self

        let headerNib = UINib.init(nibName: String(describing: DeviceLimitReachedView.self), bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: String(describing: DeviceLimitReachedView.self))

        let nib = UINib.init(nibName: String(describing: DeviceManagementCell.self), bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: String(describing: DeviceManagementCell.self))

        self.removeDeviceEvent.subscribe { event in
            if let deviceKey = event.element {
                DependencyFactory.sharedFactory.accountManager.removeDevice(with: deviceKey) { _ in
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension DeviceDataSourceAndDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let user = user, user.hasTooManyDevices else { return nil }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: DeviceLimitReachedView.self))
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
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
        cell.setup(with: devices[indexPath.row], event: removeDeviceEvent)

        return cell
    }
}
