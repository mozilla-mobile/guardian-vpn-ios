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
        let daysFormatter = DateComponentsFormatter()
        daysFormatter.allowedUnits = [.day]
        daysFormatter.unitsStyle = .full

        let hoursFormatter = DateComponentsFormatter()
        hoursFormatter.zeroFormattingBehavior = .pad
        hoursFormatter.allowedUnits = [.hour, .minute, .second]
        hoursFormatter.unitsStyle = .positional

        connectedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            let time = Date().timeIntervalSince(self?.tunnelManager.tunnelProviderManager?.connection.connectedDate ?? Date())

            guard let daysString = daysFormatter.string(from: time),
                let hoursString = hoursFormatter.string(from: TimeInterval(Int(time) % 86400))
                else { return }

            let connectedTime: String
            if time < 86400 {
                connectedTime = hoursString
            } else {
                connectedTime = "\(daysString) \(hoursString)"
            }

            DispatchQueue.main.async { [weak self] in
                self?.subtitleLabel.text = "\(state.subtitle) • \(connectedTime)"
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
