// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import RxSwift
import RxCocoa
import NetworkExtension

enum VPNState {
    case off
    case connecting
    case connected
    case switching
}

class VPNToggleView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var globeImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var vpnSwitch: UISwitch!

    public var vpnSwitchEvent: ControlProperty<Bool>?
    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(String(describing: VPNToggleView.self), owner: self, options: nil)
        self.view.frame = self.bounds
        self.addSubview(self.view)

        vpnSwitchEvent = vpnSwitch.rx.isOn

        NotificationCenter.default.rx
            .notification(Notification.Name.NEVPNStatusDidChange)
            .compactMap { ($0.object as? NETunnelProviderSession)?.status }
            .startWith(DependencyFactory.sharedFactory.tunnelManager.tunnelProviderManager?.connection.status ?? .disconnected)
            .subscribe { [weak self] statusEvent in
                guard let status = statusEvent.element else { return }
                DispatchQueue.main.async { [weak self] in
                    switch status {
                    case .invalid:
                        self?.titleLabel.text = "VPN is invalid"
                        self?.subtitleLabel.text = "Placeholder Text"
                        self?.vpnSwitch.isOn = false
                    case .disconnected:
                        self?.titleLabel.text = "VPN is off"
                        self?.subtitleLabel.text = "Turn it on to protect your entire device"
                        self?.vpnSwitch.isOn = false
                    case .connecting:
                        self?.titleLabel.text = "VPN is connecting"
                        self?.subtitleLabel.text = "Placeholder Text"
                        self?.vpnSwitch.isOn = true
                    case .connected:
                        self?.titleLabel.text = "VPN is on"
                        self?.subtitleLabel.text = "Your entire device is protected"
                        self?.vpnSwitch.isOn = true
                    case .reasserting:
                        self?.titleLabel.text = "VPN is reasserting"
                        self?.subtitleLabel.text = "Placeholder Text"
                        self?.vpnSwitch.isOn = true
                    case .disconnecting:
                        self?.titleLabel.text = "VPN is disconnecting"
                        self?.subtitleLabel.text = "Placeholder Text"
                        self?.vpnSwitch.isOn = false
                    @unknown default:
                        self?.titleLabel.text = "VPN status is unknown"
                        self?.subtitleLabel.text = "Placeholder Text."
                        self?.vpnSwitch.isOn = false
                    }
                }
        }.disposed(by: disposeBag)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        styleViews()
    }

    func styleViews() {
        titleLabel.font = UIFont.vpnTitleFont
        titleLabel.textColor = UIColor.guardianBlack
        subtitleLabel.font = UIFont.vpnSubtitleFont
        subtitleLabel.textColor = UIColor.guardianGrey

        vpnSwitch.onTintColor = UIColor.toggleColor
    }

    public func applyDropShadow() {
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        backgroundColor = UIColor.clear

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2.0
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    // MARK: State Cha
}
