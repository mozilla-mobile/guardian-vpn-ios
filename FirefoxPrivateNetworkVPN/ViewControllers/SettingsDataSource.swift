//
//  SettingsDataSource
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

class SettingsDataSource: NSObject, UITableViewDataSource {
    // MARK: - Properties
    private let representedObject: [SettingsItem]
    private let cellName = String(describing: AccountInformationCell.self)
    private let signoutCellName = String(describing: SignoutTableViewCell.self)
    private let headerName = String(describing: AccountInformationHeader.self)
    private var account: Account? { return DependencyFactory.sharedFactory.accountManager.account }
    private let disposeBag = DisposeBag()

    let rowSelected = PublishSubject<NavigableItem>()
    let headerButtonSelected = PublishSubject<NavigableItem>()
    let signoutSelected = PublishSubject<Void>()

    // MARK: - Initialization
    init(with tableView: UITableView) {
        representedObject = [.device, .help, .about, .feedback, .signout]
        super.init()
        tableView.delegate = self
        tableView.dataSource = self

        let cellNib = UINib.init(nibName: cellName, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: cellName)

        let signoutCellNib = UINib.init(nibName: signoutCellName, bundle: nil)
        tableView.register(signoutCellNib, forCellReuseIdentifier: signoutCellName)

        let headerNib = UINib.init(nibName: headerName, bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: headerName)
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        representedObject.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if representedObject[indexPath.row] == .signout {
            return setupSignoutCell(tableView, cellForRowAt: indexPath) ?? UITableViewCell(frame: .zero)
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? AccountInformationCell
            else { return UITableViewCell(frame: .zero) }

        let settingsItem = representedObject[indexPath.row]
        cell.setup(settingsItem, isDeviceAdded: account?.hasDeviceBeenAdded ?? false)

        return cell
    }

    private func setupSignoutCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> SignoutTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: signoutCellName, for: indexPath) as? SignoutTableViewCell

        //swiftlint:disable:next trailing_closure
        cell?.signoutSubject.subscribe(onNext: { [weak self] in
            self?.signoutSelected.onNext(())
        }).disposed(by: disposeBag)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let action = representedObject[indexPath.row].action {
            rowSelected.onNext(action)
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if representedObject[indexPath.row] == .signout {
            return SignoutTableViewCell.height
        }
        return AccountInformationCell.height
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AccountInformationHeader.height
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerName) as? AccountInformationHeader

        //swiftlint:disable:next trailing_closure
        headerView?.buttonTappedSubject.subscribe(onNext: { [weak self] navigableItem in
            self?.headerButtonSelected.onNext(navigableItem)
            }).disposed(by: disposeBag)

        return headerView
    }
}
