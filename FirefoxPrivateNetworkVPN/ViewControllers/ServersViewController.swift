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

    private var initialVpnState: VPNState?
    private var dataSource: ServersDataSource?
    private var viewModel: ServerListViewModel?
    private var tunnelManager = DependencyManager.shared.tunnelManager
    private var disposeBag = DisposeBag()

    // MARK: - Initialization
    init(viewModel: ServerListViewModel = ServerListViewModel()) {
        super.init(nibName: String(describing: Self.self), bundle: nil)

        self.viewModel = viewModel
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

        initialVpnState = tunnelManager.stateEvent.value
        if let state = initialVpnState {
            updateTitle(with: state)
        }

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = true
        }

        if let selectedCityIndexPath = self.viewModel?.selectedCityIndexPath {
            self.tableView?.scrollToRow(at: selectedCityIndexPath, at: .middle, animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initialVpnState = nil

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = false
        }
    }

    // MARK: - Setup
    private func setupTitle() {
        navigationItem.title = LocalizedString.serversNavTitle.value
        navigationController?.navigationBar.setTitleFont()
    }

    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(
            top: 0, left: 0,
            bottom: UIScreen.isiPad ? 64 : 32,
            right: 0)

        if let viewModel = viewModel {
            dataSource = ServersDataSource(with: tableView, viewModel: viewModel)
        }

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
                // Prevents modal from closing unintentionally
                if self?.initialVpnState != prevState {
                    self?.closeModal()
                }
            case (.switching, .on):
                // Prevents modal from closing unintentionally
                if self?.initialVpnState != prevState {
                    self?.closeModal()
                }
            default:
                break
            }
        }).disposed(by: disposeBag)

        tunnelManager
            .stateEvent
            .asDriver(onErrorJustReturn: .off)
            .drive(onNext: { [weak self] state in
                self?.updateTitle(with: state)
            }).disposed(by: disposeBag)

        viewModel?.vpnSelection
            .do(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.closeModal()
            }).disposed(by: disposeBag)

        viewModel?.toggleSection
            .subscribe(onNext: { [weak self] section, rows, isExpanded in
                guard let self = self else { return }

                self.tableView.performBatchUpdates({
                    if isExpanded {
                        self.tableView.insertRows(at: rows, with: .top)
                    } else {
                        self.tableView.deleteRows(at: rows, with: .top)
                    }
                }, completion: { _ in
                    let sectionHeader = IndexPath(row: 0, section: section)
                    self.tableView.reloadRows(at: [sectionHeader], with: .none)
                })
            }).disposed(by: disposeBag)
    }

    private func updateTitle(with state: VPNState) {
        switch state {
        case .switching, .connecting, .disconnecting:
            title = state.title
        default:
            title = LocalizedString.serversNavTitle.value
        }

        tableView.reloadData()
    }
}
