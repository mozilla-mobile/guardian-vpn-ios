//
//  AboutDataSource
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

class AboutDataSource: NSObject, UITableViewDataSource {
    // MARK: Properties
    private let representedObject: [AboutCell]
    private let headerName = String(describing: AboutHeaderTableViewCell.self)
    private let cellName = String(describing: HyperlinkCell.self)

    let rowSelected = PublishSubject<URL?>()

    // MARK: Initialization
    init(with tableView: UITableView) {
        representedObject = [.header,
                             .row(.terms),
                             .row(.privacy)]
        super.init()
        tableView.delegate = self
        tableView.dataSource = self

        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView.register(headerNib, forCellReuseIdentifier: headerName)

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        representedObject.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard case .row(let hyperLink) = representedObject[indexPath.row] else {
            return tableView.dequeueReusableCell(withIdentifier: headerName) ?? UITableViewCell(frame: .zero)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? HyperlinkCell
        cell?.setup(as: hyperLink)

        return cell ?? UITableViewCell(frame: .zero)
    }
}

// MARK: UITableViewDelegate
extension AboutDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case .row(let hyperLink) = representedObject[indexPath.row] else { return }

        rowSelected.onNext(hyperLink.url)

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard case .row = representedObject[indexPath.row] else {
            return UITableView.automaticDimension
        }

        return HyperlinkCell.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard case .row = representedObject[indexPath.row] else {
            return AboutHeaderTableViewCell.estimatedHeight
        }

        return HyperlinkCell.height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

private enum AboutCell {
    case header
    case row(HyperlinkItem)
}
