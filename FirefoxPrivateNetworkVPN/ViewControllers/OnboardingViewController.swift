//
//  LandingViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class OnboardingViewController: UIViewController, Navigating {

    static var navigableItem: NavigableItem = .landing

    @IBOutlet private weak var getStartedButton: UIButton!
    @IBOutlet private weak var learnMoreButton: UIButton!
    @IBOutlet private weak var buttonStackView: UIStackView!
    @IBOutlet private weak var buttonStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!

    var type: OnboardingViewType

    init(for type: OnboardingViewType) {
        self.type = type
        OnboardingViewController.navigableItem = type == .landing ? .landing : .carousel
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        switch type {
        case .landing:
            titleLabel.text = LocalizedString.landingTitle.value
            subtitleLabel.text = LocalizedString.landingSubtitle.value
            getStartedButton.setTitle(LocalizedString.getStarted.value, for: .normal)
            learnMoreButton.setTitle(LocalizedString.learnMore.value, for: .normal)
            imageView.image = UIImage(named: "logo")

        case .noLogs:
            titleLabel.text = LocalizedString.noLogsTitle.value
            subtitleLabel.text = LocalizedString.noLogsSubtitle.value
            imageView.image = UIImage(named: "carousel_padlock")
            buttonStackView.isHidden = true

        case .encryption:
            titleLabel.text = LocalizedString.encryptionTitle.value
            subtitleLabel.text = LocalizedString.encryptionSubtitle.value
            imageView.image = UIImage(named: "carousel_encryption")
            buttonStackView.isHidden = true

        case .manyServers:
            titleLabel.text = LocalizedString.manyServersTitle.value
            subtitleLabel.text = LocalizedString.manyServersSubtitle.value
            imageView.image = UIImage(named: "carousel_globe")
            buttonStackView.isHidden = true

        case .getStarted:
            titleLabel.text = LocalizedString.getStartedTitle.value
            subtitleLabel.text = LocalizedString.getStartedSubtitle.value
            imageView.image = UIImage(named: "carousel_meter")
            learnMoreButton.removeFromSuperview()
            getStartedButton.setTitle(LocalizedString.getStarted.value, for: .normal)
            buttonStackViewBottomConstraint.constant = 48
        }
    }

    @IBAction func getStarted() {
        navigate(to: .login)
    }

    @IBAction func learnMore() {
        navigate(to: .carousel)
    }
}

enum OnboardingViewType {
    case landing
    case noLogs
    case encryption
    case manyServers
    case getStarted
}
