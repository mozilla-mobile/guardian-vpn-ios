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
    private weak var tableView: UITableView?

    private let disposeBag = DisposeBag()
    private let headerCellName = String(describing: CountryVPNCell.self)
    private let cellName = String(describing: CityVPNCell.self)

    // MARK: - Initialization
    init(with tableView: UITableView, viewModel: ServerListViewModel) {
        self.tableView = tableView
        self.viewModel = viewModel
        super.init()

        tableView.delegate = self
        tableView.dataSource = self

        let headerNib = UINib.init(nibName: headerCellName, bundle: nil)
        tableView.register(headerNib, forCellReuseIdentifier: headerCellName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)
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
            let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellName, for: indexPath) as? CountryVPNCell
            headerCell?.setup(with: viewModel.getCountryCellModel(at: indexPath.section))

            return headerCell ?? UITableViewCell(frame: .zero)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? CityVPNCell
        cell?.setup(with: viewModel.getCityCellModel(at: indexPath))

        return cell ?? UITableViewCell(frame: .zero)
    }
}

// MARK: - UITableViewDelegate
extension ServersDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.cellSelection.onNext(indexPath)
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
}
