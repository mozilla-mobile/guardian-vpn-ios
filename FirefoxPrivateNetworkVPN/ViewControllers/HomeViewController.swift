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

    @IBOutlet var navigationTitleLabel: UILabel!
    @IBOutlet var vpnToggleView: VPNToggleView!
    @IBOutlet var selectConnectionLabel: UILabel!
    @IBOutlet var vpnSelectionView: CurrentVPNSelectorView!
    @IBOutlet weak var warningToastView: WarningToastView!

    private let pinger = LongPinger()
    private let timerFactory = ConnectionTimerFactory()
    private let rxValueObserving = ConnectionRxValue()
    private let tunnelManager = DependencyFactory.sharedFactory.tunnelManager
    private lazy var connectionHealthMonitor = {
        ConnectionHealthMonitor(pinger: self.pinger, timerFactory: self.timerFactory, rxValueObserving: self.rxValueObserving)
    }()

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
        addTapGesture()
        subscribeToToggle()
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

    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectVpn))
        vpnSelectionView.addGestureRecognizer(tapGesture)
    }

    private func subscribeToToggle() {
        vpnToggleView.vpnSwitchEvent?.skip(1).subscribe { [weak self] isOnEvent in
            guard
                let self = self,
                let isOn = isOnEvent.element
            else { return }

            if isOn {
                self.connectToTunnel()
            } else {
                self.tunnelManager.stop()
            }
        }.disposed(by: disposeBag)
    }

    private func connectToTunnel() {
        let currentDevice = DependencyFactory.sharedFactory.accountManager.account?.currentDevice

        //swiftlint:disable:next trailing_closure
        tunnelManager.connect(with: currentDevice)
            .subscribe(onError: { _ in
                self.warningToastView.show(message: self.formatErrorMessage(with: .couldNotConnectVPN), action: self.connectToTunnel)
            }).disposed(by: self.disposeBag)
    }

    private func formatErrorMessage(with error: GuardianError) -> NSMutableAttributedString {
        let message = NSMutableAttributedString(string: error.localizedDescription)
        let actionMessage = NSAttributedString(string: LocalizedString.toastTryAgain.value, attributes: [
            .font: UIFont.custom(.interSemiBold, size: 13),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        message.append(NSAttributedString(string: " "))
        message.append(actionMessage)
        return message
    }

    @objc func selectVpn() {
        UIView.animate(withDuration: 0.3, animations: {
            self.vpnSelectionView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            self.navigate(to: .servers)
            UIView.animate(withDuration: 0.7,
                           delay: 0,
                           usingSpringWithDamping: 0.4,
                           initialSpringVelocity: 6.0,
                           options: .allowUserInteraction,
                           animations: {
                            self.vpnSelectionView.transform = CGAffineTransform.identity
            }, completion: nil)
        })
    }
}
