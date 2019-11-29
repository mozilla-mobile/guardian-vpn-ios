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

class VPNToggleView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var globeImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var vpnSwitch: UISwitch!
    @IBOutlet weak var containingView: UIView!

    var vpnSwitchEvent: ControlProperty<Bool>?
    private let disposeBag = DisposeBag()
    private var timerDisposeBag = DisposeBag()
    private var smallLayer = CAShapeLayer()
    private var mediumLayer = CAShapeLayer()
    private var largeLayer = CAShapeLayer()
    private var tunnelManager = DependencyFactory.sharedFactory.tunnelManager
    private var connectionHealthMonitor = DependencyFactory.sharedFactory.connectionHealthMonitor
    private var updateUIEvent = PublishSubject<Void>()

    lazy var daysFormatter: DateComponentsFormatter = {
        let daysFormatter = DateComponentsFormatter()
        daysFormatter.allowedUnits = [.day]
        daysFormatter.unitsStyle = .full
        return daysFormatter
    }()

    lazy var hoursFormatter: DateComponentsFormatter = {
        let hoursFormatter = DateComponentsFormatter()
        hoursFormatter.zeroFormattingBehavior = .pad
        hoursFormatter.allowedUnits = [.hour, .minute, .second]
        hoursFormatter.unitsStyle = .positional
        return hoursFormatter
    }()

    private var formattedTime: String {
        let time = self.tunnelManager.timeSinceConnected

        guard let daysString = daysFormatter.string(from: time),
            let hoursString = hoursFormatter.string(from: TimeInterval(Int(time) % 86400))
            else { return "" }

        let connectedTime: String
        if time < 86400 {
            connectedTime = hoursString
        } else {
            connectedTime = "\(daysString) \(hoursString)"
        }
        return connectedTime
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed(String(describing: VPNToggleView.self), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)

        let vpnStateEvent = tunnelManager.stateEvent
            .observeOn(MainScheduler.instance)
            .skip(1)

        Observable
            .zip(vpnStateEvent, updateUIEvent.startWith(())) { [weak self] state, _ in
                self?.update(with: state)

                DispatchQueue.main.asyncAfter(deadline: .now() + (state.delay ?? 0)) {
                    self?.updateUIEvent.onNext(())
                }
        }
        .subscribe()
        .disposed(by: disposeBag)
    }

    override func awakeFromNib() {
        update(with: .off)
        vpnSwitchEvent = vpnSwitch.rx.isOn
    }

    private func showConnectedTime(state: VPNState) {

        let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        let connectionState = connectionHealthMonitor.currentState.asObservable().subscribeOn(ConnectionHealthMonitor.scheduler).distinctUntilChanged()

        //swiftlint:disable trailing_closure
        Observable.combineLatest(timer, connectionState)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _, connectionState in
                guard let self = self else { return }

                switch connectionState {
                    //  ======== TODO: Pelase refactor :)======
                case .unstable:
                    let icon = NSTextAttachment()
                    let iconImage = UIImage(named: "icon_unstable")!
                    icon.image = iconImage
                    icon.centerImage(with: self.subtitleLabel)
                    let iconString = NSAttributedString(attachment: icon)

                    let stateString = NSAttributedString(string: LocalizedString.homeSubtitleUnstable.value, attributes: [
                        NSAttributedString.Key.foregroundColor: UIColor.custom(.yellow50)
                    ])

                    let checkConnectionString = NSAttributedString(string: LocalizedString.homeSubtitleCheckConnection.value)

                    let fullString = NSMutableAttributedString(attributedString: iconString)
                    fullString.append(stateString)
                    fullString.append(checkConnectionString)
                    self.subtitleLabel.attributedText = NSAttributedString(attributedString: fullString)

                case .noSignal:
                    let icon = NSTextAttachment()
                    icon.image = UIImage(named: "icon_nosignal")
                    icon.centerImage(with: self.subtitleLabel)
                    let iconString = NSAttributedString(attachment: icon)

                    let stateString = NSAttributedString(string: LocalizedString.homeSubtitleUnstable.value, attributes: [
                        NSAttributedString.Key.foregroundColor: UIColor.custom(.red50)
                    ])

                    let checkConnectionString = NSAttributedString(string: LocalizedString.homeSubtitleCheckConnection.value)
                    let fullString = NSMutableAttributedString(attributedString: iconString)
                    fullString.append(stateString)
                    fullString.append(checkConnectionString)
                    self.subtitleLabel.attributedText = NSAttributedString(attributedString: fullString)
                    // ===============
                default:
                    self.subtitleLabel.text = String(format: LocalizedString.homeSubtitleOn.value, self.formattedTime)
                }
            }).disposed(by: timerDisposeBag)
    }

    // MARK: State Change

    private func update(with state: VPNState) {
        titleLabel.text = state.title
        titleLabel.textColor = state.textColor
        subtitleLabel.textColor = state.subtitleColor
        vpnSwitch.isOn = state.isToggleOn
        vpnSwitch.isEnabled = state.isEnabled
        globeImageView.image = state.globeImage
        globeImageView.alpha = state.globeOpacity
        view.backgroundColor = state.backgroundColor

        if state == .on {
            showConnectedTime(state: state)
            if let hostAddress = VPNCity.fetchFromUserDefaults()?.servers.first?.ipv4Gateway {
                connectionHealthMonitor.start(hostAddress: hostAddress)
            }

            let position = CGPoint(x: globeImageView.center.x, y: globeImageView.center.y + containingView.frame.minY)
            smallLayer.position = position
            mediumLayer.position = position
            largeLayer.position = position
            smallLayer.addPulse(delay: 0.0)
            mediumLayer.addPulse(delay: 2.0)
            largeLayer.addPulse(delay: 4.0)
            layer.addSublayer(smallLayer)
            layer.addSublayer(mediumLayer)
            layer.addSublayer(largeLayer)
        } else {
            connectionHealthMonitor.reset()
            timerDisposeBag = DisposeBag()

            subtitleLabel.text = state.subtitle
            smallLayer.removeFromSuperlayer()
            mediumLayer.removeFromSuperlayer()
            largeLayer.removeFromSuperlayer()
        }
    }
}
