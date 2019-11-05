//
//  SettingsDataSourceAndDelegate
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

enum SettingsItem {
    case device
    case help
    case about

    var title: String {
        switch self {
        case .device: return LocalizedString.settingsItemDevices.value
        case .help: return LocalizedString.settingsItemHelp.value
        case .about: return LocalizedString.settingsItemAbout.value
        }
    }

    var image: UIImage? {
        switch self {
        case .device: return #imageLiteral(resourceName: "icon_device")
        case .help: return #imageLiteral(resourceName: "icon_help")
        case .about: return #imageLiteral(resourceName: "icon_about")
        }
    }

    var action: NavigableItem {
        switch self {
        case .device: return .devices
        case .help: return .help
        case .about: return .about
        }
    }
}

class SettingsDataSourceAndDelegate: NSObject {
    private let settings: [SettingsItem] = [.device,
                                    .help,
                                    .about]
    private weak var tableView: UITableView?
    private let headerName = String(describing: AccountInformationHeader.self)
    private let cellName = String(describing: AccountInformationCell.self)

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        registerViews()
    }

    private func registerViews() {
        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView?.register(headerNib, forHeaderFooterViewReuseIdentifier: headerName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView?.register(cellNib, forCellReuseIdentifier: cellName)
    }
}

// MARK: - UITableViewDelegate
extension SettingsDataSourceAndDelegate: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerName) as? AccountInformationHeader,
            let user = DependencyFactory.sharedFactory.accountManager.user
            else { return nil }
        headerView.setup(with: user)
        return headerView
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return AccountInformationCell.height
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return AccountInformationHeader.height
    }
}

// MARK: - UITableViewDataSource
extension SettingsDataSourceAndDelegate: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        settings.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? AccountInformationCell else {
            return UITableViewCell(frame: .zero)
        }
        cell.setup(settings[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        DependencyFactory.sharedFactory.navigationCoordinator
            .navigate(from: .settings, to: settings[indexPath.row].action)
    }
}
