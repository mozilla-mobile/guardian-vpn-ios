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
    @IBOutlet private weak var inAppPurchaseBannerView: TopBannerView!
    @IBOutlet private weak var versionUpdateBannerView: TopBannerView!
    @IBOutlet private weak var vpnStackView: UIStackView!

    private let pinger = LongPinger()
    private let timerFactory = ConnectionTimerFactory()
    private let rxValueObserving = ConnectionRxValue()
    private let tunnelManager = DependencyManager.shared.tunnelManager
    private let releaseMonitor = DependencyManager.shared.releaseMonitor
    private let accountManager = DependencyManager.shared.accountManager
    private let heartbeatMonitor = DependencyManager.shared.heartbeatMonitor
    private let disposeBag = DisposeBag()
    private let notificationFeedback = UINotificationFeedbackGenerator()

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
        subscribeToVpnStates()
        subscribeToErrors()
        subscribeToVersionUpdates()
        subscribeToSubscription()
        getProducts()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        vpnSelectionView.view.cornerRadius = vpnSelectionView.view.frame.height/2
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heartbeatMonitor.pollNow()
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

        vpnToggleView.tapGestureHandler = { [weak self] in
            self?.notificationFeedback.notificationOccurred(.error)
            self?.inAppPurchaseBannerView.vibrate()
            self?.versionUpdateBannerView.vibrate()
        }
    }

    private func subscribeToVpnStates() {
        //swiftlint:disable trailing_closure
        tunnelManager.stateEvent
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard case .disconnecting(.some(let error)) = state else {
                    self?.vpnToggleView.update(with: state)
                    return
                }
                self?.warningToastView.show(message: NSAttributedString.formattedError(error),
                                            action: self?.connectToTunnel)
            }).disposed(by: disposeBag)

        tunnelManager.stateEvent
            .withPrevious()
            .map { return (previous: $0[0], current: $0[1]) }
            .subscribe(onNext: { previous, current in
                switch (previous, current) {
                case (.switching, .off):
                    NotificationCenter.default.post(Notification(name: .switchServerError))
                default: break
                }
            }).disposed(by: disposeBag)
    }

    private func connectToTunnel() {
        //swiftlint:disable:next trailing_closure
        tunnelManager.connect()
            .subscribe(onError: { [weak self] _ in
                guard let self = self else { return }
                self.warningToastView.show(message: NSAttributedString.formattedError(TunnelError.couldNotConnect),
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
                self.warningToastView.show(message: NSAttributedString.formattedError(TunnelError.couldNotConnect),
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
                    let text = NSAttributedString.formatted(LocalizedString.bannerFeaturesAvailable.value,
                                                            actionMessage: LocalizedString.updateNow.value)
                    self.versionUpdateBannerView.configure(text: text, action: {
                        self.navigate(to: .appStore)
                    }, dismiss: {
                        UIView.animate(withDuration: 0.3, animations: {
                            self.versionUpdateBannerView.alpha = 0
                        }, completion: { _ in
                            self.versionUpdateBannerView.isHidden = true
                            self.inAppPurchaseBannerView.isHidden = !self.versionUpdateBannerView.isHidden || (self.accountManager.account?.isSubscriptionActive ?? false)
                        })
                    })
                    self.versionUpdateBannerView.isHidden = false
                case .required:
                    Logger.global?.log(message: "Required update detected")
                    self.versionUpdateBannerView.isHidden = true
                    self.navigate(to: .requiredUpdate)
                default: //.none or nil
                    self.versionUpdateBannerView.isHidden = true
                }
                self.inAppPurchaseBannerView.isHidden = !self.versionUpdateBannerView.isHidden || (self.accountManager.account?.isSubscriptionActive ?? false)
            }).disposed(by: disposeBag)
    }

    private func subscribeToSubscription() {
        accountManager.isSubscriptionActive
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isActiveSubscription in
                guard let self = self else { return }

                let text = NSAttributedString.formatted(LocalizedString.bannerInAppPurchase.value,
                                                        actionMessage: LocalizedString.tryMozillaVPN.value)
                self.inAppPurchaseBannerView.configure(text: text, action: {
                    self.navigate(to: .product)
                })
                self.inAppPurchaseBannerView.isHidden = !self.versionUpdateBannerView.isHidden || isActiveSubscription
                self.vpnToggleView.update(with: self.tunnelManager.stateEvent.value)
            }).disposed(by: disposeBag)
    }

    private func getProducts() {
        accountManager.getProducts { result in
            if case .success(let products) = result {
                StoreManager.shared.startProductRequest(with: products)
            }
        }
    }

    func showIAPToast(context: NavigableContext?) {
        guard let context = context else { return }
        switch context {
        case .iapSucceed:
            inAppPurchaseBannerView.isHidden = true
            let attributedString = NSAttributedString.formatted("Subscription confirmed!", actionMessage: "Turn on VPN")
            warningToastView.show(type: .positive, message: attributedString, action: connectToTunnel)
        case .error(let error):
            let attributedString = NSAttributedString.formattedError(error)
            warningToastView.show(message: attributedString) {
                self.navigate(to: .product)
            }
        default:
            return
        }
    }

    // MARK: - VPN Selection handling
    @IBAction private func vpnSelectionTouchUpInside() {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut, animations: {
            self.vpnSelectionView.showUnselected()
        }, completion: { isComplete in
            if isComplete {
                self.navigate(to: .servers)
            }
        })
    }

    @IBAction private func vpnSelectionTouchDown() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.vpnSelectionView.showSelected()
        }, completion: nil)
    }

    @IBAction private func vpnSelectionTouchDragOutside() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.vpnSelectionView.showUnselected()
        }, completion: nil)
    }
}
