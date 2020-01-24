//
//  VPNToggleView
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
import RxCocoa
import NetworkExtension
import Lottie

class VPNToggleView: UIView {
    @IBOutlet private var view: UIView!
    @IBOutlet private var globeImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var vpnSwitch: UISwitch!
    @IBOutlet weak var vpnToggleButton: UIButton!
    @IBOutlet private weak var containingView: UIView!
    @IBOutlet weak var backgroundAnimationContainerView: UIView!

    var connectionHandler: (() -> Void)?
    var disconnectionHandler: (() -> Void)?

    private let disposeBag = DisposeBag()
    private var timerDisposeBag = DisposeBag()
    private var tunnelManager = DependencyFactory.sharedFactory.tunnelManager
    private var connectionHealthMonitor = DependencyFactory.sharedFactory.connectionHealthMonitor
    private let rippleAnimationView = AnimationView()

    private lazy var hoursFormatter: DateComponentsFormatter = {
        let hoursFormatter = DateComponentsFormatter()
        hoursFormatter.zeroFormattingBehavior = .pad
        hoursFormatter.allowedUnits = [.hour, .minute, .second]
        hoursFormatter.unitsStyle = .positional

        return hoursFormatter
    }()

    private lazy var daysFormatter: DateComponentsFormatter = {
        let daysFormatter = DateComponentsFormatter()
        daysFormatter.allowedUnits = [.day]
        daysFormatter.unitsStyle = .full

        return daysFormatter
    }()

    private var formattedTime: String {
        let day = 86400.0
        let secondsSinceConnected = self.tunnelManager.timeSinceConnected

        switch secondsSinceConnected {
        case 0..<day:
            let roundedSecondsSinceConnected = TimeInterval(Int(secondsSinceConnected) % 86400)
            return hoursFormatter.string(from: roundedSecondsSinceConnected) ?? ""

        case day...(6 * day):
            return daysFormatter.string(from: secondsSinceConnected) ?? ""

        case (6 * day)...(7 * day):
            return LocalizedString.homeSubtitleWeek.value

        default:
            return LocalizedString.homeSubtitleWeekPlus.value
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed(String(describing: VPNToggleView.self), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }

    override func awakeFromNib() {
        setupRippleAnimation()
    }

    private func setupRippleAnimation() {
        let rippleAnimation = Animation.named("ripples", subdirectory: "Animations")
        rippleAnimationView.animation = rippleAnimation
        rippleAnimationView.contentMode = .scaleAspectFit
        rippleAnimationView.backgroundBehavior = .pauseAndRestore
        backgroundAnimationContainerView.addSubview(rippleAnimationView)
    }

    override func layoutSubviews() {
        rippleAnimationView.frame = backgroundAnimationContainerView.bounds
    }

    // MARK: - Actions
    @IBAction func toggleTapped() {
        if !vpnSwitch.isOn {
            connectionHandler?()
        } else {
            disconnectionHandler?()
        }
    }

    // MARK: State Change
    func update(with state: VPNState) {
        titleLabel.text = state.title
        titleLabel.textColor = state.textColor
        subtitleLabel.text = state.subtitle
        subtitleLabel.textColor = state.subtitleColor
        vpnSwitch.isOn = state.isToggleOn
        vpnSwitch.isUserInteractionEnabled = state.isEnabled
        vpnSwitch.alpha = state.isEnabled ? 1 : 0.5
        vpnToggleButton.isUserInteractionEnabled = state.isEnabled
        globeImageView.image = state.globeImage
        globeImageView.alpha = state.globeOpacity
        view.backgroundColor = state.backgroundColor

        switch state {
        case .on:
            startRippleAnimation()
            setSubtitle(with: ConnectionHealth.stable)
            getConnectionTimeAndHealth()
        case .disconnecting:
            stopRippleAnimation()
            resetConnectionTimeAndHealth()
        default:
            resetConnectionTimeAndHealth()
        }
    }

    // MARK: - Animations
    private var isRippleAnimationPlaying: Bool {
        rippleAnimationView.isAnimationPlaying
    }

    private func startRippleAnimation() {
        rippleAnimationView.play(fromFrame: 0, toFrame: 75, loopMode: .playOnce) { [weak self] isComplete in
            if isComplete {
                self?.rippleAnimationView.play(fromFrame: 75, toFrame: 120, loopMode: .loop, completion: nil)
            }
        }
    }

    private func stopRippleAnimation() {
        self.rippleAnimationView.stop()
        rippleAnimationView.play(fromFrame: 120, toFrame: 210, loopMode: .playOnce) { [weak self] isComplete in
            if isComplete {
                self?.rippleAnimationView.stop()
            }
        }
    }

    // MARK: Connection Health and Time

    private func getConnectionTimeAndHealth() {
        let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        let connectionState = connectionHealthMonitor.currentState.distinctUntilChanged()

        //swiftlint:disable trailing_closure
        Observable.combineLatest(timer, connectionState)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _, connectionHealth in
                guard let self = self else { return }
                self.setSubtitle(with: connectionHealth)

                if connectionHealth == .unstable || connectionHealth == .noSignal {
                    self.rippleAnimationView.stop()
                } else {
                    if !self.isRippleAnimationPlaying {
                        self.startRippleAnimation()
                    }
                }
            }).disposed(by: timerDisposeBag)

        if let hostAddress = VPNCity.fetchFromUserDefaults()?.servers.first?.ipv4Gateway {
            connectionHealthMonitor.start(hostAddress: hostAddress)
        }
    }

    private func resetConnectionTimeAndHealth() {
        connectionHealthMonitor.reset()
        timerDisposeBag = DisposeBag()
    }

    private func setSubtitle(with connectionHealth: ConnectionHealth) {
        guard connectionHealth == .unstable || connectionHealth == .noSignal else {
            self.subtitleLabel.text = String(format: connectionHealth.subtitleText, self.formattedTime)
            return
        }

        let icon = NSTextAttachment()
        if let iconImage = connectionHealth.icon {
            icon.image = iconImage
            icon.centerImage(with: self.subtitleLabel)
        }
        let iconString = NSAttributedString(attachment: icon)

        let stateString = NSAttributedString(string: connectionHealth.subtitleText, attributes: [
            NSAttributedString.Key.foregroundColor: connectionHealth.textColor
        ])

        let checkConnectionString = NSAttributedString(string: LocalizedString.homeSubtitleCheckConnection.value)

        let fullString = NSMutableAttributedString(attributedString: iconString)
        fullString.append(stateString)
        fullString.append(checkConnectionString)
        self.subtitleLabel.attributedText = NSAttributedString(attributedString: fullString)
    }
}
