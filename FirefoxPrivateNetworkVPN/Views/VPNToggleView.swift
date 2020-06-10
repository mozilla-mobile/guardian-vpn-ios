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
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var vpnSwitch: UISwitch!
    @IBOutlet weak var vpnToggleButton: UIButton!
    @IBOutlet private weak var containingView: UIView!
    @IBOutlet weak var globeAnimationContainer: UIView!
    @IBOutlet weak var backgroundAnimationContainerView: UIView!

    var connectionHandler: (() -> Void)?
    var disconnectionHandler: (() -> Void)?

    private var currentState = VPNState.off
    private let disposeBag = DisposeBag()
    private var timerDisposeBag = DisposeBag()
    private let tunnelManager = DependencyManager.shared.tunnelManager
    private let accountManager = DependencyManager.shared.accountManager
    private let connectionHealthMonitor = DependencyManager.shared.connectionHealthMonitor
    private var globeAnimationView: AnimationView?
    private var rippleAnimationView: AnimationView?
    private var tapHaptics = UIImpactFeedbackGenerator(style: .light)

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
        super.awakeFromNib()
        globeAnimationView = createAnimation(for: "globe", in: globeAnimationContainer)
        globeAnimationView?.respectAnimationFrameRate = true
        globeAnimationView?.loopMode = .playOnce
        rippleAnimationView = createAnimation(for: "ripples", in: backgroundAnimationContainerView)
        rippleAnimationView?.respectAnimationFrameRate = true
        rippleAnimationView?.animationSpeed = 0.5
        view.cornerRadius = UIScreen.isiPad ? 16 : 8

        update(with: .off)
    }

    private func createAnimation(for name: String, in containerView: UIView) -> AnimationView {
        let animation = Animation.named(name, subdirectory: "Animations")
        let animationView = AnimationView()
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        containerView.addSubview(animationView)

        return animationView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        globeAnimationView?.frame = globeAnimationContainer.bounds
        rippleAnimationView?.frame = backgroundAnimationContainerView.bounds
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

        sendNotification(to: state)
        updateToggle(to: state)
        animateGlobe(to: state)

        view.backgroundColor = state.backgroundColor

        switch state {
        case .on:
            startRippleAnimation()
            setSubtitle(with: ConnectionHealth.stable)
            getConnectionTimeAndHealth()
        case .disconnecting:
            stoppingRippleAnimation()
            resetConnectionTimeAndHealth()
        case .off:
            connectionHealthMonitor.stop()
            resetConnectionTimeAndHealth()
            resetRippleAnimation()
        default:
            resetConnectionTimeAndHealth()
        }

        currentState = state
    }

    private func updateToggle(to newState: VPNState) {
        switch (currentState, newState) {
        case (.off, .connecting),
             (.connecting, .on),
             (.on, .switching),
             (.switching, .on),
             (.switching, .off),
             (.on, .disconnecting),
             (.disconnecting, .off):
            vpnSwitch.setOn(newState.isToggleOn, animated: true)
            tapHaptics.impactOccurred()
        default:
            vpnSwitch.setOn(newState.isToggleOn, animated: false)
        }

        vpnSwitch.isUserInteractionEnabled = newState.isEnabled
        vpnSwitch.alpha = newState.isEnabled ? 1 : 0.5

        vpnToggleButton.isUserInteractionEnabled = newState.isEnabled
    }

    // MARK: - Animations
    private var isRippleAnimationPlaying: Bool {
        return rippleAnimationView?.isAnimationPlaying ?? false
    }

    private func startRippleAnimation() {
        rippleAnimationView?.play(fromFrame: 0, toFrame: 75, loopMode: .playOnce) { [weak self] isComplete in
            if isComplete {
                self?.rippleAnimationView?.play(fromFrame: 75, toFrame: 120, loopMode: .loop, completion: nil)
            }
        }
    }

    private func stoppingRippleAnimation() {
        rippleAnimationView?.play(fromFrame: 120, toFrame: 210, loopMode: .playOnce)
    }

    private func resetRippleAnimation() {
        rippleAnimationView?.stop()
        rippleAnimationView?.currentFrame = 0
    }

    private func animateGlobe(to newState: VPNState) {
        switch (currentState, newState) {
        case (.off, .connecting):
            globeAnimationView?.play(fromFrame: 0, toFrame: 15)
        case (.connecting, .on):
            globeAnimationView?.play(fromFrame: 15, toFrame: 30)
        case (.on, .switching):
            globeAnimationView?.play(fromFrame: 30, toFrame: 45)
        case (.switching, .on):
            globeAnimationView?.play(fromFrame: 45, toFrame: 30)
        case (.on, .disconnecting):
            globeAnimationView?.play(fromFrame: 30, toFrame: 45)
        case (.disconnecting, .off), (.switching, .off):
            globeAnimationView?.play(fromFrame: 45, toFrame: 60)
        case (.off, .on): // handles app re-launch
            globeAnimationView?.play(fromFrame: 30, toFrame: 30)
        case (.on, .off): // handles VPN settings change outside of the app
            globeAnimationView?.play(fromFrame: 60, toFrame: 60)
        default: break
        }
    }

    private func animateGlobe(connected: Bool) {
        if connected {
            globeAnimationView?.play(fromFrame: 0, toFrame: 30, loopMode: .playOnce, completion: nil)
        } else {
            if let globeAnimationView = globeAnimationView, globeAnimationView.currentFrame == 30 {
                globeAnimationView.play(fromFrame: 30, toFrame: 60, loopMode: .playOnce, completion: nil)
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
                    self.resetRippleAnimation()
                } else {
                    if !self.isRippleAnimationPlaying {
                        self.startRippleAnimation()
                    }
                }
            }).disposed(by: timerDisposeBag)

        connectionState.subscribe { connectionHealth in
            if let connectionHealth = connectionHealth.element {
                switch connectionHealth {
                case .stable:
                    guard case .switching(_, _) = self.currentState else {
                        LocalNotificationFactory.showNotification(when: .vpnConnected)
                        return
                    }
                case .unstable:
                    LocalNotificationFactory.showNotification(when: .vpnUnstable)
                case .noSignal:
                    LocalNotificationFactory.showNotification(when: .vpnNoSignal)
                default:
                    break
                }
            }
        }.disposed(by: timerDisposeBag)

        if let hostAddress = accountManager.selectedCity?.selectedServer?.ipv4Gateway {
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

    private func sendNotification(to newState: VPNState) {
        switch (currentState, newState) {
        case (.switching, .on):
            LocalNotificationFactory.showNotification(when: .vpnSwitched(currentState.subtitle))
        case (.disconnecting, .off), (.switching, .off):
            LocalNotificationFactory.showNotification(when: .vpnDisconnected)
        default: break
        }
    }
}
