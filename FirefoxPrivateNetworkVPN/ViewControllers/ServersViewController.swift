//
//  ServersViewController
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
import os.log

class ServersViewController: UIViewController, Navigating {

    // MARK: - Properties
    static var navigableItem: NavigableItem = .servers

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: ServersDataSource?
    private var viewModel: ServerListViewModel?
    private var tunnelManager = DependencyFactory.sharedFactory.tunnelManager
    private var disposeBag = DisposeBag()

    // MARK: - Initialization
    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarForModalPresentation()
        setupTableView()
        setupTitle()
        setupObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = true
        }

        if let selectedCityIndexPath = viewModel?.selectedCityIndexPath {
            tableView?.scrollToRow(at: selectedCityIndexPath, at: .middle, animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = false
        }
    }

    func reload(section: Int) -> Single<Void> {
        return Single<Void>.create { [weak self] resolver in
            self?.tableView?.reloadSections(IndexSet(integer: section), with: .automatic)
            resolver(.success(()))
            return Disposables.create()
        }
    }

    // MARK: - Setup
    private func setupTitle() {
        navigationItem.title = LocalizedString.serversNavTitle.value
        navigationController?.navigationBar.setTitleFont()
    }

    private func setupTableView() {
        tableView.contentInsetAdjustmentBehavior = .never
        let serverListViewModel = ServerListViewModel()
        viewModel = serverListViewModel
        dataSource = ServersDataSource(with: tableView, viewModel: serverListViewModel)

        tableView.reloadData()
    }

    //swiftlint:disable trailing_closure
    private func setupObservers() {
        tunnelManager
            .stateEvent
            .withPrevious(startWith: .off)
            .subscribe(onNext: { [weak self] prevState, currentState in
            switch (prevState, currentState) {
            case (.connecting, .on):
                self?.closeModal()
            case (.switching, .on):
                self?.closeModal()
            default:
                break
            }
        }).disposed(by: disposeBag)

        tunnelManager
            .stateEvent
            .skip(1)
            .asDriver(onErrorJustReturn: .off)
            .drive(onNext: { [weak self] state in
                switch state {
                case .connecting, .switching, .disconnecting:
                    self?.title = state.title
                    self?.tableView.isUserInteractionEnabled = false
                default:
                    self?.title = LocalizedString.serversNavTitle.value
                    self?.tableView.isUserInteractionEnabled = true
                }
            }).disposed(by: disposeBag)

        viewModel?.vpnSelection
            .delay(.milliseconds(150), scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Single<Void> in
                guard let self = self,
                    let device = DependencyFactory.sharedFactory.accountManager.account?.currentDevice else {
                        OSLog.log(.error, "No device found when switching VPN server")
                        return .never()
                }

                return self.tunnelManager.switchServer(with: device)
        }.catchError { error -> Observable<Void> in
            OSLog.logTunnel(.error, error.localizedDescription)
            NotificationCenter.default.post(Notification(name: .switchServerError))
            return Observable.just(())
        }
        .subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }

            // Dismisses server list if tunnel is not already established
            let currentState = self.tunnelManager.stateEvent.value
            if currentState == .off {
                self.closeModal()
            }
        })
        .disposed(by: disposeBag)
    }
}
