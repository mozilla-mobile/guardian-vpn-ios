//
//  HomeViewController
//  MozillaVPNmacOS
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Cocoa
import Lottie
import RxSwift

class HomeViewController: NSViewController {

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var subtitleLabel: NSTextField!
    @IBOutlet weak var vpnToggleButton: NSButton!
    @IBOutlet weak var vpnSwitch: NSSwitch!

    @IBOutlet weak var globeAnimationContainer: NSView!
    @IBOutlet weak var backgroundAnimationContainerView: NSView!
    @IBOutlet weak var backgroundView: NSView!

    @IBOutlet weak var countryFlagImageView: NSImageView!
    @IBOutlet weak var countryTitleLabel: NSTextField!
    @IBOutlet weak var deviceCountTitleLabel: NSTextField!

    @IBOutlet weak var serverSelectionView: NSView!
    @IBOutlet weak var deviceCountView: NSView!

    private var globeAnimationView: AnimationView?
    private var rippleAnimationView: AnimationView?

    private var currentState = VPNState.off
    private var tunnelsManager: MacOSTunnelManager?
    private let accountManager = DependencyManager.shared.accountManager
    private let connectionHealthMonitor = DependencyManager.shared.connectionHealthMonitor

    private let disposeBag = DisposeBag()
    private var timerDisposeBag = DisposeBag()

    var observationToken: AnyObject?

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
        let secondsSinceConnected = tunnelsManager?.timeSinceConnected ?? 0.0

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

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        observationToken = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                print("\(error.alertText)")
            case .success(let tunnelsManager):
                if let accountManager = self.accountManager as? AccountManager {
                    self.tunnelsManager = MacOSTunnelManager(tunnelsManager: tunnelsManager, accountManager: accountManager)
                    self.subscribeToVPNState()
                }
            }
        }

        setupUI()
        update(with: .off)
    }

    private func setupUI() {
        globeAnimationView = createAnimation(for: "globe", in: globeAnimationContainer)
        globeAnimationView?.respectAnimationFrameRate = true
        globeAnimationView?.loopMode = .playOnce
        rippleAnimationView = createAnimation(for: "ripples", in: backgroundAnimationContainerView)
        rippleAnimationView?.respectAnimationFrameRate = true
        rippleAnimationView?.animationSpeed = 0.5

        if let city = accountManager.selectedCity,
            let flagCode = city.flagCode?.lowercased() {
            print("city: \(city.name)")
            print("flagCode: \(flagCode)")
            countryTitleLabel.stringValue = city.name
            countryFlagImageView.image = NSImage(named: "flag_\(flagCode)")
        }
    }

    private func createAnimation(for name: String, in containerView: NSView) -> AnimationView {
        let animation = Animation.named(name, subdirectory: "Animations")
        let animationView = AnimationView()
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        containerView.addSubview(animationView)

        return animationView
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        globeAnimationView?.frame = globeAnimationContainer.bounds
        rippleAnimationView?.frame = backgroundAnimationContainerView.bounds
    }

    @IBAction func toggleTapped(_ sender: NSButton) {
        if vpnSwitch.state == .off {
            self.tunnelsManager?.connect()
        } else {
            self.tunnelsManager?.stop()
        }
    }

    // MARK: State Change

    func subscribeToVPNState() {
        observationToken = tunnelsManager?.selectedTunnel?.observe(\.status) { tunnel, _ in
            self.update(with: VPNState(with: tunnel.status))
        }
    }

    private func update(with state: VPNState) {
        titleLabel.stringValue = state.title
        titleLabel.textColor = state.textColor

        subtitleLabel.stringValue = state.subtitle
        subtitleLabel.textColor = state.subtitleColor

        sendNotification(to: state)
        updateToggle(to: state)
        animateGlobe(to: state)

        backgroundView.layer?.backgroundColor = state.backgroundColor.cgColor

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
            vpnSwitch.state = newState.isToggleOn ? .on : .off
        default:
            vpnSwitch.state = newState.isToggleOn ? .on : .off
        }

        vpnSwitch.alphaValue = newState.isEnabled ? 1 : 0.5
    }

    private func setSubtitle(with connectionHealth: ConnectionHealth) {
        guard connectionHealth == .unstable || connectionHealth == .noSignal else {
            self.subtitleLabel.stringValue = String(format: connectionHealth.subtitleText, self.formattedTime)
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
        self.subtitleLabel.attributedStringValue = NSAttributedString(attributedString: fullString)
    }

    // MARK: - Connection Health and Time

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
                case .unstable:
                    LocalNotificationFactory.shared.showNotification(when: .vpnUnstable)
                case .noSignal:
                    LocalNotificationFactory.shared.showNotification(when: .vpnNoSignal)
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
        case (.off, .connecting), (.disconnecting, .connecting):
            globeAnimationView?.play(fromFrame: 0, toFrame: 15)
        case (.connecting, .on):
            globeAnimationView?.play(fromFrame: 15, toFrame: 30)
        case (.on, .switching):
            globeAnimationView?.play(fromFrame: 30, toFrame: 45)
        case (.switching, .on):
            globeAnimationView?.play(fromFrame: 45, toFrame: 30)
        case (.on, .disconnecting), (.connecting, .disconnecting):
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

    // MARK: - Notification

    private func sendNotification(to newState: VPNState) {
        switch (currentState, newState) {
        case (.switching, .on):
            if let isSwitchingInProgress = AppExtensionUserDefaults.standard.value(forKey: .isSwitchingInProgress) as? Bool,
                isSwitchingInProgress {
                LocalNotificationFactory.shared.showNotification(when: .vpnSwitched(currentState.subtitle))
            }
            AppExtensionUserDefaults.standard.set(false, forKey: .isSwitchingInProgress)
        default: break
        }
    }

    @IBAction func showServerList(_ sender: NSButton) {

    }

    @IBAction func showDeviceList(_ sender: NSButton) {

    }
}

extension NSTextAttachment {

    func centerImage(with label: NSTextField) {
        guard let image = image,
            let font = label.font else { return }

        bounds = CGRect(x: 0, y: (font.capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
    }
}
