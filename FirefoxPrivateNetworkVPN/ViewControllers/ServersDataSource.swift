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
import RxSwift

class ServersDataSource: NSObject, UITableViewDataSource {

    // MARK: - Properties
    private let viewModel: ServerListViewModel
    private weak var tableView: UITableView?

    private let countryCellIdentifier = String(describing: CountryVPNCell.self)
    private let cityCellIdentifier = String(describing: CityVPNCell.self)

    // MARK: - Initialization
    init(with tableView: UITableView, viewModel: ServerListViewModel) {
        self.tableView = tableView
        self.viewModel = viewModel
        super.init()

        tableView.delegate = self
        tableView.dataSource = self

        let countryCellNib = UINib.init(nibName: countryCellIdentifier, bundle: nil)
        tableView.register(countryCellNib, forCellReuseIdentifier: countryCellIdentifier)

        let cityCellNib = UINib.init(nibName: cityCellIdentifier, bundle: nil)
        tableView.register(cityCellNib, forCellReuseIdentifier: cityCellIdentifier)
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getRowCount(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.isFirstRowInSection {
            let countryCell = tableView.dequeueReusableCell(withIdentifier: countryCellIdentifier, for: indexPath) as? CountryVPNCell
            countryCell?.setup(with: viewModel.getCountryCellModel(at: indexPath.section), shouldHideTopLine: indexPath.isFirstSection)

            return countryCell ?? UITableViewCell(frame: .zero)
        }

        let cityCell = tableView.dequeueReusableCell(withIdentifier: cityCellIdentifier, for: indexPath) as? CityVPNCell
        cityCell?.setup(with: viewModel.getCityCellModel(at: indexPath))

        return cityCell ?? UITableViewCell(frame: .zero)
    }
}

// MARK: - UITableViewDelegate
extension ServersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.cellSelection.onNext(indexPath)
    }

    //Need to set the estimatedHeightForRow since using automatic dimensions
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.isFirstRowInSection ? CountryVPNCell.estimatedHeight : CityVPNCell.estimatedHeight
    }
}

private extension IndexPath {
    var isFirstRowInSection: Bool {
        return row == 0
    }

    var isFirstSection: Bool {
        return section == 0
    }
}
