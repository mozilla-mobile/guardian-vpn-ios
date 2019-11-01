// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class SettingsDataSourceAndDelegate: NSObject {
    private var tableView: UITableView
    let settings: [SettingsItem] = [.device,
                                    .help,
                                    .about]
    private weak var navigationCoordinator: Navigating?

    init(tableView: UITableView, navigationCoordinator: Navigating) {
        self.tableView = tableView
        self.navigationCoordinator = navigationCoordinator
        super.init()
        setup()
    }

    private func setup() {
        tableView.dataSource = self
        tableView.delegate = self

        let headerNib = UINib.init(nibName: String(describing: AccountInformationHeader.self), bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: String(describing: AccountInformationHeader.self))

        let nib = UINib.init(nibName: String(describing: AccountInformationCell.self), bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: String(describing: AccountInformationCell.self))
    }
}

// MARK: - UITableViewDelegate
extension SettingsDataSourceAndDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: AccountInformationHeader.self)) as? AccountInformationHeader,
            let user = DependencyFactory.sharedFactory.accountManager.user
            else { return nil }
        headerView.setup(with: user)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountInformationCell.height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AccountInformationHeader.height
    }
}

// MARK: - UITableViewDataSource
extension SettingsDataSourceAndDelegate: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccountInformationCell.self), for: indexPath) as? AccountInformationCell else {
            return UITableViewCell(frame: .zero)
        }
        cell.setup(settings[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navigationCoordinator = navigationCoordinator {
            navigationCoordinator.navigate.onNext(settings[indexPath.row].action)
        }
    }
}

enum SettingsItem {
    case device
    case help
    case about

    var title: String {
        switch self {
        case .device: return "My devices"
        case .help: return "Get help"
        case .about: return "About"
        }
    }

    var image: UIImage? {
        switch self {
        case .device: return UIImage(named: "device_icon")
        case .help: return UIImage(named: "help_icon")
        case .about: return UIImage(named: "about_icon")
        }
    }

    var action: NavigationAction {
        switch self {
        case .device: return .devicesSelection
        case .help: return .helpSelection
        case .about: return .aboutSelection
        }
    }
}
