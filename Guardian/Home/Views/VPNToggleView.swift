// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import RxSwift
import RxCocoa
import NetworkExtension

class VPNToggleView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var globeImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var vpnSwitch: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    public var vpnSwitchEvent: ControlProperty<Bool>?
    private let disposeBag = DisposeBag()
    private var smallLayer = CAShapeLayer()
    private var mediumLayer = CAShapeLayer()
    private var largeLayer = CAShapeLayer()
    private var tunnelManager = DependencyFactory.sharedFactory.tunnelManager
    private var connectedTimer: Timer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(String(describing: VPNToggleView.self), owner: self, options: nil)
        self.view.frame = self.bounds
        self.addSubview(self.view)

        vpnSwitchEvent = vpnSwitch.rx.isOn

        NotificationCenter.default.rx
            .notification(Notification.Name.NEVPNStatusDidChange)
            .compactMap { ($0.object as? NETunnelProviderSession)?.status }
            .startWith(tunnelManager.tunnelProviderManager?.connection.status ?? .disconnected)
            .subscribe { [weak self] statusEvent in
                guard let status = statusEvent.element,
                    let self = self else { return }
                print(status)
                DispatchQueue.main.async {
                    self.update(with: VPNState(with: status))
                }
            }.disposed(by: disposeBag)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        styleViews()
    }

    private func showConnectedTime(state: VPNState) {
        let format = DateComponentsFormatter()
        format.zeroFormattingBehavior = .pad
        format.allowedUnits = [.hour, .minute, .second]
        format.unitsStyle = .positional

        connectedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            let time = Date().timeIntervalSince(self?.tunnelManager.tunnelProviderManager?.connection.connectedDate ?? Date())
            guard let timeString = format.string(from: time) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.subtitleLabel.text = "\(state.subtitle) • \(timeString)"
            }
        }
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
    private func update(with state: VPNState) {
        titleLabel.text = state.title
        titleLabel.textColor = state.textColor
        subtitleLabel.textColor = state.textColor
        vpnSwitch.isOn = state.isToggleOn
        globeImageView.image = state.globeImage
        view.backgroundColor = state.backgroundColor
        if state != .on {
            connectedTimer?.invalidate()
            subtitleLabel.text = state.subtitle
        }

        if state.showActivityIndicator {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }

        if state == .on {
            smallLayer.position = globeImageView.center
            mediumLayer.position = globeImageView.center
            largeLayer.position = globeImageView.center
            smallLayer.addPulse(delay: 0.0)
            mediumLayer.addPulse(delay: 2.0)
            largeLayer.addPulse(delay: 4.0)
            view.layer.addSublayer(smallLayer)
            view.layer.addSublayer(mediumLayer)
            view.layer.addSublayer(largeLayer)

            showConnectedTime(state: state)
        }
    }
}

private extension CAShapeLayer {
    func addPulse(delay: CFTimeInterval) {
    let circlePath = UIBezierPath(arcCenter: .zero,
                                   radius: 60,
                                   startAngle: 0,
                                   endAngle: 2 * CGFloat.pi,
                                   clockwise: true)

        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineWidth = 5
        opacity = 0.0
        path = circlePath.cgPath

        let expandAnimation = CABasicAnimation(keyPath: "transform.scale")
        expandAnimation.duration = 6
        expandAnimation.toValue = 2.07
        expandAnimation.beginTime = CACurrentMediaTime() + delay
        expandAnimation.repeatCount = .infinity

        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.duration = 6
        lineWidthAnimation.toValue = 1
        lineWidthAnimation.beginTime = CACurrentMediaTime() + delay
        lineWidthAnimation.repeatCount = .infinity

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 6
        opacityAnimation.fromValue = 0.12
        opacityAnimation.toValue = 0.0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        opacityAnimation.beginTime = CACurrentMediaTime() + delay
        opacityAnimation.repeatCount = .infinity

        add(expandAnimation, forKey: "expand")
        add(opacityAnimation, forKey: "opacity")
        add(lineWidthAnimation, forKey: "linewidth")
    }
}

enum VPNState {
    case on
    case off
    case connecting
    case switching

    init(with status: NEVPNStatus) {
        switch status {
        case .invalid, .disconnected, .disconnecting:
            self = .off
        case .connecting, .reasserting:
            self = .connecting
        case .connected:
            self = .on
        default:
            self = .off
        }
    }
}

extension VPNState {
    var textColor: UIColor {
        switch self {
        case .off:
            return UIColor.guardianGrey
        default:
            return UIColor.white
        }
    }

    var title: String {
        switch self {
        case .off:
            return "VPN is off"
        case .connecting:
            return "Connecting"
        case .on:
            return "VPN is on"
        case .switching:
            return "Switching"
        default:
            return "Unknown"
        }
    }

    var subtitle: String {
        switch self {
        case .off:
            return "Turn it on to protect your entire device"
        case .connecting, .switching:
            return "You will be protected shortly"
        case .on:
            return "Secure and protected"
        default:
            return ""
        }
    }

    var globeImage: UIImage? {
        switch self {
        case .off:
            return UIImage(named: "globe_off")
        case .connecting:
            return UIImage(named: "globe_connecting")
        case .on:
            return UIImage(named: "globe_on")
        case .switching:
            return UIImage(named: "globe_switching")
        default:
            return UIImage(named: "globe_off")
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .off:
            return UIColor.white
        default:
            return UIColor.backgroundPurple
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
        case .on, .connecting, .switching:
            return true
        default:
            return false
        }
    }
}
