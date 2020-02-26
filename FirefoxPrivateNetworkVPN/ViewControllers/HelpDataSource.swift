//
//  HelpDataSource
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

class HelpDataSource: NSObject, UITableViewDataSource {
    // MARK: Properties
    private let representedObject: [HyperlinkItem]
    private let cellName = String(describing: HyperlinkCell.self)

    let rowSelected = PublishSubject<URL?>()

    // MARK: Initialization
    init(with tableView: UITableView) {
        representedObject = [.contact,
                             .support]
        super.init()
        tableView.delegate = self
        tableView.dataSource = self

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        representedObject.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? HyperlinkCell else {
            return UITableViewCell(frame: .zero)
        }
        cell.setup(as: representedObject[indexPath.row])
        return cell
    }
}

// MARK: UITableViewDelegate
extension HelpDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowSelected.onNext(representedObject[indexPath.row].url)

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HyperlinkCell.height
    }
}
