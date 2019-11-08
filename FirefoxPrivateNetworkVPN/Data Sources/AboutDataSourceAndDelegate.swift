//
//  AboutDataSourceAndDelegate
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

class AboutDataSourceAndDelegate: NSObject {
    private let aboutItems: [HyperlinkItem] = [.terms,
                                              .privacy]
    private weak var tableView: UITableView?
    private let headerName = String(describing: AboutHeaderView.self)
    private let cellName = String(describing: HyperlinkCell.self)

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        registerViews()
    }

    func registerViews() {
        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView?.register(headerNib, forHeaderFooterViewReuseIdentifier: headerName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView?.register(cellNib, forCellReuseIdentifier: cellName)
    }
}

// MARK: - UITableViewDelegate
extension AboutDataSourceAndDelegate: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: headerName)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return HyperlinkCell.height
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return AboutHeaderView.height
    }
}

// MARK: - UITableViewDataSource
extension AboutDataSourceAndDelegate: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return aboutItems.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? HyperlinkCell else {
            return UITableViewCell(frame: .zero)
        }
        cell.setup(as: aboutItems[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        if let url = aboutItems[indexPath.row].url {
            UIApplication.shared.open(url)
        }
    }
}
