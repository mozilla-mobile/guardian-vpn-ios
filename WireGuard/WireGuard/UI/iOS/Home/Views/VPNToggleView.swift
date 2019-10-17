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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
                guard let status = statusEvent.element,
                    let self = self else { return }
                
                DispatchQueue.main.async {
                    self.update(with: status)
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
    private func update(with status: NEVPNStatus) {
        titleLabel.text = status.title
        subtitleLabel.text = status.subtitle
        titleLabel.textColor = status.textColor
        subtitleLabel.textColor = status.textColor
        vpnSwitch.isOn = status.isToggleOn
        globeImageView.image = status.globeImage
        view.backgroundColor = status.backgroundColor
        
        if status.showActivityIndicator {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

extension NEVPNStatus {
    var textColor: UIColor {
        switch self {
        case .invalid, .disconnected, .reasserting:
            return UIColor.guardianGrey
        case .connecting, .connected, .disconnecting:
            return UIColor.white
        default:
            return UIColor.guardianGrey
        }
    }

    var title: String {
        switch self {
        case .invalid, .disconnected:
            return "VPN is off"
        case .connecting, .reasserting:
            return "Connecting"
        case .connected:
            return "VPN is on"
        case .disconnecting:
            return "Switching"
        default:
            return "Unknown"
        }
    }

    var subtitle: String {
        switch self {
        case .invalid, .disconnected:
            return "Turn it on to protect your entire device"
        case .connecting, .reasserting:
            return "You will be protected shortly"
        case .connected:
            return "Secure and protected"
        default:
            return ""
        }
    }

    var globeImage: UIImage? {
        switch self {
        case .invalid, .disconnected:
            return UIImage(named: "globe_off")
        case .connecting, .reasserting:
            return UIImage(named: "globe_connecting")
        case .connected:
            return UIImage(named: "globe_on")
        case .disconnecting:
            return UIImage(named: "globe_switching")
        default:
            return UIImage(named: "globe_off")
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .invalid, .disconnected, .reasserting:
            return UIColor.backgroundOffWhite
        case .connecting, .connected, .disconnecting:
            return UIColor.backgroundPurple
        default:
            return UIColor.backgroundOffWhite
        }
    }

    var showActivityIndicator: Bool {
        switch self {
        case .connecting:
            return true
        default:
            return false
        }
    }

    var isToggleOn: Bool {
        switch self {
        case .connected, .connecting, .reasserting:
            return true
        default:
            return false
        }
    }
}
