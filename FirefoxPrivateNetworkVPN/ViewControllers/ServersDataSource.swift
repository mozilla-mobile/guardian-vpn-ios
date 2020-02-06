//
//  ServersDataSource
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import NetworkExtension
import RxSwift
import os.log

class ServersDataSource: NSObject, UITableViewDataSource {
    // MARK: - Properties
    private let viewModel: ServerListViewModel
    private let representedObject: [VPNCountry]
    private weak var tableView: UITableView?
    private lazy var sectionExpandedStates: [Int: Bool] = {
        var states = [Int: Bool]()
        if let selectedSection = selectedIndexPath?.section {
            states[selectedSection] = true
        }

        return states
    }()

    private let headerTapPublishSubject = PublishSubject<ServerSectionHeaderViewCell>()
    private let disposeBag = DisposeBag()
    private let headerCellName = String(describing: ServerSectionHeaderViewCell.self)
    private let cellName = String(describing: CityVPNCell.self)

    private(set) var selectedIndexPath: IndexPath?
    let vpnSelection = PublishSubject<Void>()

    // MARK: - Initialization
    init(with tableView: UITableView, viewModel: ServerListViewModel = ServerListViewModel()) {
        self.tableView = tableView
        self.viewModel = viewModel
        representedObject = DependencyFactory.sharedFactory.accountManager.availableServers ?? []
        super.init()
        selectedIndexPath = getSelectedIndexPath()

        tableView.delegate = self
        tableView.dataSource = self

        let headerNib = UINib.init(nibName: headerCellName, bundle: nil)
        tableView.register(headerNib, forCellReuseIdentifier: headerCellName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)

//        listenForHeaderTaps()
    }

    // MARK: - Setup
    private func getSelectedIndexPath() -> IndexPath? {
        guard let currentCity = VPNCity.fetchFromUserDefaults() else { return nil }

        for (countryIndex, country) in representedObject.enumerated() {
            for (cityIndex, city) in country.cities.enumerated() where city == currentCity {
                return IndexPath(row: cityIndex, section: countryIndex)
            }
        }
        return nil
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getRowCount(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellName, for: indexPath) as? ServerSectionHeaderViewCell else { return UITableViewCell(frame: .zero) }

//            cell.setup(with: viewModel.getCountry(at: indexPath.section))
            return headerCell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? CityVPNCell
            else { return UITableViewCell(frame: .zero) }
        let city = representedObject[indexPath.section].cities[indexPath.row - 1]
//        cell.setup(with: viewModel.getCity(at: indexPath))
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ServersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            viewModel.toggle(section: indexPath.section)
            return
        }

        viewModel.selectCity(at: indexPath)

    }
}

// Preventing the `grouped` style from introducing extra spacing between sections
// Reference: https://stackoverflow.com/a/56978339
extension ServersDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
