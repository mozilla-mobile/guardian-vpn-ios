//
//  HomeViewController
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

class HomeViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .home

    @IBOutlet private weak var navigationTitleLabel: UILabel!
    @IBOutlet private weak var vpnToggleView: VPNToggleView!
    @IBOutlet private weak var selectConnectionLabel: UILabel!
    @IBOutlet private weak var vpnSelectionView: CurrentVPNSelectorView!
    @IBOutlet private weak var warningToastView: WarningToastView!
    @IBOutlet private weak var versionUpdateToastView: VersionUpdateToastView!
    @IBOutlet private weak var vpnStackView: UIStackView!

    private let pinger = LongPinger()
    private let timerFactory = ConnectionTimerFactory()
    private let rxValueObserving = ConnectionRxValue()
    private let tunnelManager = DependencyFactory.sharedFactory.tunnelManager
    private let releaseMonitor = DependencyFactory.sharedFactory.releaseMonitor
    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
        setupTabBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setStrings()
        setupToggleView()
        subscribeToErrors()
        subscribeToVersionUpdates()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        vpnSelectionView.view.cornerRadius = vpnSelectionView.view.frame.height/2
    }

    private func setStrings() {
        navigationTitleLabel.text = LocalizedString.homeApplicationName.value
        selectConnectionLabel.text = LocalizedString.homeSelectConnection.value
    }

    private func setupTabBar() {
        let tag: TabTag = .home
        tunnelManager.stateEvent.subscribe { [weak self] event in
            let image = event.element == .on ? #imageLiteral(resourceName: "tab_vpnOn") : #imageLiteral(resourceName: "tab_vpnOff")
            self?.tabBarItem = UITabBarItem(title: LocalizedString.homeTabName.value, image: image, tag: tag)
        }.disposed(by: disposeBag)
    }

    private func setupToggleView() {
        vpnToggleView.connectionHandler = { [weak self] in
            self?.connectToTunnel()
        }

        vpnToggleView.disconnectionHandler = { [weak self] in
            self?.tunnelManager.stop()
        }

        //swiftlint:disable trailing_closure
        tunnelManager.stateEvent
            .withPrevious(startWith: tunnelManager.stateEvent.value)
            .filter { previous, current in
                return previous != current
            }.flatMap { [weak self] previous, current -> Observable<VPNState> in
                switch (previous, current) {
                case (VPNState.connecting, VPNState.on), (VPNState.disconnecting, VPNState.off):
                    return Observable.just(current).delay(DispatchTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
                case (VPNState.switching, VPNState.on):
                    return Observable.just(current).delay(DispatchTimeInterval.milliseconds(2000), scheduler: MainScheduler.instance)
                case (VPNState.off, VPNState.disconnecting):
                    self?.warningToastView.show(message: NSAttributedString.formattedError(.couldNotConnectVPN),
                                                action: self?.connectToTunnel)

                    return Observable.just(current)
                default: return Observable.just(current)
                }
        }
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] state in
            self?.vpnToggleView.update(with: state)
        }).disposed(by: disposeBag)
    }

    private func connectToTunnel() {
        let currentDevice = DependencyFactory.sharedFactory.accountManager.account?.currentDevice

        //swiftlint:disable:next trailing_closure
        tunnelManager.connect(with: currentDevice)
            .subscribe(onError: { [weak self] _ in
                guard let self = self else { return }
                self.warningToastView.show(message: NSAttributedString.formattedError(.couldNotConnectVPN),
                                           action: self.connectToTunnel)
            }).disposed(by: self.disposeBag)
    }

    private func subscribeToErrors() {
        //swiftlint:disable trailing_closure
        Observable.merge(
            NotificationCenter.default.rx.notification(.switchServerError),
            NotificationCenter.default.rx.notification(.startTunnelError))
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.warningToastView.show(message: NSAttributedString.formattedError(.couldNotConnectVPN),
                                           action: self.connectToTunnel)
            })
        .disposed(by: disposeBag)
    }

    private func subscribeToVersionUpdates() {
        releaseMonitor.updateStatus
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                switch value {
                case .optional:
                    self.versionUpdateToastView.isHidden = false
                case .required:
                    Logger.global?.log(message: "Required update detected")
                    self.versionUpdateToastView.isHidden = true
                    self.navigate(to: .requiredUpdate)
                default: //.none or nil
                    self.versionUpdateToastView.isHidden = true
                }
            }).disposed(by: disposeBag)
    }

    // MARK: - VPN Selection handling
    @IBAction private func vpnSelectionTouchUpInside() {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut, animations: {
            self.vpnSelectionView.transform = CGAffineTransform.identity
        }, completion: { isComplete in
            if isComplete {
                self.navigate(to: .servers)
            }
        })
    }

    @IBAction private func vpnSelectionTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.vpnSelectionView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }, completion: nil)
    }

    @IBAction private func vpnSelectionTouchDragOutside() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.vpnSelectionView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}
