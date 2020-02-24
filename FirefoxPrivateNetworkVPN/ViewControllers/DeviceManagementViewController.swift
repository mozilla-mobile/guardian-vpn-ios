//
//  DeviceManagementViewController
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

class DeviceManagementViewController: UIViewController, Navigating {
    // MARK: Properties
    static var navigableItem: NavigableItem = .devices

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var warningToastView: WarningToastView!

    private var dataSource: DeviceManagementDataSource?
    private var viewModel: DeviceManagementViewModel
    private var account: Account? { return DependencyFactory.sharedFactory.accountManager.account }
    private let disposeBag = DisposeBag()

    private var formattedDeviceCountTitle: String {
        guard let user = account?.user else { return "" }
        let count = viewModel.deviceList.count
        return String(format: LocalizedString.devicesCount.value, "\(count)", "\(user.maxDevices)")
    }

    private lazy var backButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "icon_backChevron"),
                               style: .plain,
                               target: self,
                               action: #selector(goBack))
    }()

    private lazy var deviceCountItem: UIBarButtonItem = {
        let deviceCountItem = UIBarButtonItem(title: formattedDeviceCountTitle,
                                              style: .plain,
                                              target: nil,
                                              action: nil)

        deviceCountItem.isEnabled = false
        deviceCountItem.setTitleTextAttributes(
            [NSAttributedString.Key.font: UIFont.custom(.inter), NSAttributedString.Key.foregroundColor: UIColor.custom(.grey40)],
            for: .disabled)

        return deviceCountItem
    }()

    // MARK: - Initialization
    init(viewModel: DeviceManagementViewModel = DeviceManagementViewModel()) {
        self.viewModel = viewModel

        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle
    //swiftlint:disable trailing_closure
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = DeviceManagementDataSource(with: tableView, viewModel: viewModel)
        tableView.tableFooterView = UIView()

        viewModel.deletionCompletedSubject
            .subscribe(onNext: { [weak self] result in
                guard let self = self, let account = self.account else { return }

                self.refreshViews()

                guard case .failure(let error) = result,
                    case .couldNotRemoveDevice(let device) = error else {
                        if account.hasDeviceBeenAdded {
                            DependencyFactory.sharedFactory.navigationCoordinator.homeTab(isEnabled: true)
                        }
                        return
                }

                self.warningToastView.show(message: NSAttributedString.formattedError(GuardianError.couldNotRemoveDevice(device))) {
                    self.viewModel.deletionConfirmedSubject.onNext(device)
                }
            }).disposed(by: disposeBag)

        viewModel.trashTappedSubject
            .subscribe(onNext: { [weak self] device in
                guard let self = self else { return }
                let confirmAlert = DependencyFactory
                    .sharedFactory
                    .navigationCoordinator
                    .createDeviceDeletionAlert(deviceName: device.name) { _ in
                        self.viewModel.deletionConfirmedSubject.onNext(device)
                        self.tableView.reloadData()
                }
                self.present(confirmAlert, animated: true, completion: nil)
            }).disposed(by: disposeBag)

        account?.getUser { [weak self] _ in
            self?.refreshViews()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // MARK: Setup
    private func setupNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil // enables back swipe

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.rightBarButtonItem = deviceCountItem

        navigationItem.title = LocalizedString.devicesNavTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey40)

        navigationItem.leftBarButtonItem = backButtonItem
    }

    private func refreshViews() {
        tableView.reloadData()
        navigationItem.rightBarButtonItem?.title = formattedDeviceCountTitle
    }

    @objc func goBack() {
        navigate(to: .settings)
    }
}
