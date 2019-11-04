//
//  VPNToggleView
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NetworkExtension

class VPNToggleView: UIView {
    @IBOutlet var globeImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var vpnSwitch: UISwitch!

    var vpnSwitchEvent: ControlProperty<Bool>?
    private let disposeBag = DisposeBag()
    private var smallLayer = CAShapeLayer()
    private var mediumLayer = CAShapeLayer()
    private var largeLayer = CAShapeLayer()
    private var tunnelManager = DependencyFactory.sharedFactory.tunnelManager
    private var connectedTimer: Timer?
    private var updateUIEvent = PublishSubject<Void>()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        vpnSwitchEvent = vpnSwitch.rx.isOn

        Observable
            .zip(tunnelManager.stateEvent, updateUIEvent.startWith(())) { [weak self] state, _ in
                DispatchQueue.main.async {
                    self?.update(with: state)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + (state.delay ?? 0)) {
                    self?.updateUIEvent.onNext(())
                }
        }
        .subscribe()
        .disposed(by: disposeBag)
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
            guard let self = self else { return }
            let time = self.tunnelManager.timeSinceConnected

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

    // MARK: State Change

    private func update(with state: VPNState) {
        titleLabel.text = state.title
        titleLabel.textColor = state.textColor
        subtitleLabel.textColor = state.textColor
        vpnSwitch.isOn = state.isToggleOn
        vpnSwitch.isEnabled = state.isEnabled
        globeImageView.image = state.globeImage
        globeImageView.alpha = state.globeOpacity
        backgroundColor = state.backgroundColor

        if state == .on {
            showConnectedTime(state: state)

            smallLayer.position = globeImageView.center
            mediumLayer.position = globeImageView.center
            largeLayer.position = globeImageView.center
            smallLayer.addPulse(delay: 0.0)
            mediumLayer.addPulse(delay: 2.0)
            largeLayer.addPulse(delay: 4.0)
            layer.addSublayer(smallLayer)
            layer.addSublayer(mediumLayer)
            layer.addSublayer(largeLayer)
        } else {
            connectedTimer?.invalidate()
            subtitleLabel.text = state.subtitle
            smallLayer.removeFromSuperlayer()
            mediumLayer.removeFromSuperlayer()
            largeLayer.removeFromSuperlayer()
        }
    }
}
