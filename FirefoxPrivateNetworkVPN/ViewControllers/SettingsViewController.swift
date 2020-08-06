//
//  SettingsViewController
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

class SettingsViewController: UIViewController, Navigating {
    // MARK: - Properties
    static var navigableItem: NavigableItem = .settings

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: SettingsDataSource?
    private let disposeBag = DisposeBag()

    private lazy var headerView: AccountInformationHeader = {
        let view = AccountInformationHeader()
        view.frame.size.height = AccountInformationHeader.height

        return view
    }()

    // MARK: - Initialization
    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
        setupTabBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = SettingsDataSource(with: tableView)
        tableView.tableFooterView = UIView()

        subscribeToSettingSelected()
        subscribeToSignoutTapped()
        subscribeToActiveSubscriptionNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        tableView.reloadData()

        DependencyManager.shared.heartbeatMonitor.pollNow()
    }

    // MARK: - Setup
    private func setupTabBar() {
        let tag: TabTag = .settings
        tabBarItem = UITabBarItem(title: LocalizedString.settingsTabName.value, image: UIImage(named: "tab_settings"), tag: tag)
    }

    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.backBarButtonItem = nil
    }

    private func subscribeToSettingSelected() {
        //swiftlint:disable:next trailing_closure
        dataSource?.settingSelected
            .subscribe(onNext: { [weak self] item in
                if item == .device, !item.isSubscriptionActive {
                    self?.navigate(to: .product)
                } else {
                    if let navigableItem = item.navigableItem {
                        self?.navigate(to: navigableItem, context: item.navigableContext)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func subscribeToSignoutTapped() {
        //swiftlint:disable:next trailing_closure
        dataSource?.signoutSelectedSubject
            .subscribe(onNext: { _ in
                DependencyManager.shared.accountManager.logout { [weak self] _ in
                    self?.navigate(to: .landing)
                }
            })
            .disposed(by: self.disposeBag)
    }

    private func subscribeToActiveSubscriptionNotification() {
        //swiftlint:disable:next trailing_closure
        NotificationCenter.default.rx
            .notification(Notification.Name.activeSubscriptionNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            }).disposed(by: disposeBag)
    }
}
