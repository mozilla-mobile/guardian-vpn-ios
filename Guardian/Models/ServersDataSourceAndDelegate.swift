// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import NetworkExtension
import RxSwift

class ServersDataSourceAndDelegate: NSObject {
    let countries: [VPNCountry]
    private var selectedIndexPath: IndexPath?
    private var sectionExpandedStates = [Int: Bool]()
    private let headerTapPublishSubject = PublishSubject<CountryVPNHeaderView>()
    private var disposeBag = DisposeBag()
    private weak var tableView: UITableView?

    // TODO: Dependency Inject
    private var accountManager = AccountManager.sharedManager
    private let tunnelsManager = GuardianTunnelManager.sharedTunnelManager

    init(countries: [VPNCountry], tableView: UITableView) {
        self.tableView = tableView
        self.countries = countries
        super.init()
        setup(with: tableView)
        listenForHeaderTaps()
    }

    private func setup(with tableView: UITableView) {
        tableView.dataSource = self
        tableView.delegate = self

        let nib = UINib.init(nibName: String(describing: CityVPNCell.self), bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: String(describing: CityVPNCell.self))

        let headerNib = UINib.init(nibName: String(describing: CountryVPNHeaderView.self), bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: String(describing: CountryVPNHeaderView.self))
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

extension ServersDataSourceAndDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CityVPNCell.self), for: indexPath) as? CityVPNCell else {
            return UITableViewCell(frame: .zero)
        }

        let city = countries[indexPath.section].cities[indexPath.row]
        cell.cityLabel.text = city.name
        cell.radioImageView.image = (indexPath == selectedIndexPath) ? UIImage(named: "On") : UIImage(named: "Off")

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionExpandedStates[section] ?? false) ? countries[section].cities.count : 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return countries.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCity = countries[indexPath.section].cities[indexPath.row]
        currentCity.saveToUserDefaults()
        tunnelsManager.cityChangedEvent.onNext(currentCity)

        if indexPath != selectedIndexPath {
            selectedIndexPath = indexPath
            tunnelsManager.switchServer(with: accountManager.currentDevice!)
            tableView.reloadData()
        }
    }
}

extension ServersDataSourceAndDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: CountryVPNHeaderView.self)) as? CountryVPNHeaderView else {
            return nil
        }
        headerView.tag = section
        headerView.flagImageView.image = UIImage(named: countries[section].code.uppercased())
        headerView.nameLabel.text = countries[section].name
        headerView.tapPublishSubject = headerTapPublishSubject
        headerView.isExpanded = sectionExpandedStates[section] ?? false

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CityVPNCell.height()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CountryVPNHeaderView.height()
    }
}
