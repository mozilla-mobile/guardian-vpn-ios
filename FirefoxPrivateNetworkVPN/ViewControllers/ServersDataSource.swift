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
    private let representedObject: [VPNCountry]
    private weak var tableView: UITableView?
    private var sectionExpandedStates = [Int: Bool]()
    private let headerTapPublishSubject = PublishSubject<CountryVPNHeaderView>()
    private let disposeBag = DisposeBag()
    private let headerName = String(describing: CountryVPNHeaderView.self)
    private let cellName = String(describing: CityVPNCell.self)

    private(set) var selectedIndexPath: IndexPath?
    let vpnSelection = PublishSubject<Void>()

    // MARK: - Initialization
    init(with tableView: UITableView) {
        self.tableView = tableView
        representedObject = DependencyFactory.sharedFactory.accountManager.availableServers ?? []
        super.init()
        selectedIndexPath = getSelectedIndexPath()

        tableView.delegate = self
        tableView.dataSource = self

        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: headerName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)

        listenForHeaderTaps()
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

    private func listenForHeaderTaps() {
        headerTapPublishSubject.subscribe { [weak self] headerEvent in
            guard let headerView = headerEvent.element,
                let tableView = self?.tableView
                else { return }
            headerView.isExpanded.toggle()
            let section = headerView.tag
            self?.sectionExpandedStates[section] = headerView.isExpanded
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }.disposed(by: disposeBag)
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return representedObject.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionExpandedStates[section, default: true])
            ? representedObject[section].cities.count
            : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? CityVPNCell
            else { return UITableViewCell(frame: .zero) }
        let city = representedObject[indexPath.section].cities[indexPath.row]
        cell.setup(city: city)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ServersDataSource: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCity = representedObject[indexPath.section].cities[indexPath.row]
        currentCity.saveToUserDefaults()
        let tunnelManager = DependencyFactory.sharedFactory.tunnelManager
        tunnelManager.cityChangedEvent.onNext(currentCity)

        if indexPath != selectedIndexPath {
            selectedIndexPath = indexPath
            tableView.reloadData()

            vpnSelection.onNext(())
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CityVPNCell.height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CountryVPNHeaderView.height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // Preventing the `grouped` style from introducing extra spacing between sections
        // Reference: https://stackoverflow.com/a/56978339
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerName) as? CountryVPNHeaderView
            else { return nil }
        headerView.tag = section
        headerView.setup(country: representedObject[section])
        headerView.tapPublishSubject = headerTapPublishSubject
        headerView.isExpanded = sectionExpandedStates[section, default: true]

        return headerView
    }
}
