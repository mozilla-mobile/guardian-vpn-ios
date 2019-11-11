//
//  HelpDataSourceAndDelegate
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class HelpDataSourceAndDelegate: NSObject {
    private let helpItems: [HyperlinkItem] = [.contact,
                                              .support]
    private weak var tableView: UITableView?
    private let cellName = String(describing: HyperlinkCell.self)

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }
}

 // MARK: - UITableViewDelegate
extension HelpDataSourceAndDelegate: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return HyperlinkCell.height
    }
}

// MARK: - UITableViewDataSource
extension HelpDataSourceAndDelegate: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return helpItems.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? HyperlinkCell else {
            return UITableViewCell(frame: .zero)
        }
        cell.setup(as: helpItems[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if let url = helpItems[indexPath.row].url {
            UIApplication.shared.open(url)
        }
    }
}
