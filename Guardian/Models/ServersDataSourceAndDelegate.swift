//
//  ServersDataSourceAndDelegate
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit
import NetworkExtension
import RxSwift

class ServersDataSourceAndDelegate: NSObject {
    private var countries: [VPNCountry]
    private var selectedIndexPath: IndexPath?
    private var sectionExpandedStates = [Int: Bool]()
    private let headerTapPublishSubject = PublishSubject<CountryVPNHeaderView>()
    private var disposeBag = DisposeBag()
    private weak var tableView: UITableView?
    private let headerName = String(describing: CountryVPNHeaderView.self)
    private let cellName = String(describing: CityVPNCell.self)

    init(tableView: UITableView) {
        self.tableView = tableView
        countries = DependencyFactory.sharedFactory.accountManager.availableServers ?? []
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        registerViews()
        listenForHeaderTaps()
    }

    private func registerViews() {
        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView?.register(headerNib, forHeaderFooterViewReuseIdentifier: headerName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView?.register(cellNib, forCellReuseIdentifier: cellName)
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
}

// MARK: - UITableViewDataSource
extension ServersDataSourceAndDelegate: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? CityVPNCell else {
            return UITableViewCell(frame: .zero)
        }
        let city = countries[indexPath.section].cities[indexPath.row]
        cell.setup(city: city)
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return (sectionExpandedStates[section] ?? false) ? countries[section].cities.count : 0
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let currentCity = countries[indexPath.section].cities[indexPath.row]
        currentCity.saveToUserDefaults()
        let tunnelManager = DependencyFactory.sharedFactory.tunnelManager
        tunnelManager.cityChangedEvent.onNext(currentCity)

        if indexPath != selectedIndexPath,
            let device = DependencyFactory.sharedFactory.accountManager.currentDevice {
            selectedIndexPath = indexPath
            tunnelManager.switchServer(with: device)
            tableView.reloadData()
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return countries.count
    }
}

// MARK: - UITableViewDelegate
extension ServersDataSourceAndDelegate: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerName) as? CountryVPNHeaderView else {
            return nil
        }
        headerView.tag = section
        headerView.setup(country: countries[section])
        headerView.tapPublishSubject = headerTapPublishSubject
        headerView.isExpanded = sectionExpandedStates[section] ?? false

        return headerView
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return CityVPNCell.height
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return CountryVPNHeaderView.height
    }
}
