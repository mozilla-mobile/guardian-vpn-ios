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

    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var type: OnboardingViewType

    init(for type: OnboardingViewType) {
        self.type = type
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
            self.titleLabel.text = LocalizedString.landingTitle.value
            self.subtitleLabel.text = LocalizedString.landingSubtitle.value
            self.getStartedButton.setTitle(LocalizedString.getStarted.value, for: .normal)
            self.learnMoreButton.setTitle(LocalizedString.learnMore.value, for: .normal)
            self.imageView.image = UIImage(named: "logo")
            
        case .activityLogs:
            self.titleLabel.text = LocalizedString.activityLogsTitle.value
            self.subtitleLabel.text = LocalizedString.activityLogsSubtitle.value
            self.getStartedButton.isHidden = true
            self.learnMoreButton.isHidden = true
            self.imageView.image = UIImage(named: "carousel_padlock")
            
        case .encryption:
            self.titleLabel.text = LocalizedString.encryptionTitle.value
            self.subtitleLabel.text = LocalizedString.encryptionSubtitle.value
            self.getStartedButton.isHidden = true
            self.learnMoreButton.isHidden = true
            self.imageView.image = UIImage(named: "carousel_encryption")
            
        case .countries:
            self.titleLabel.text = LocalizedString.countriesTitle.value
            self.subtitleLabel.text = LocalizedString.countriesSubtitle.value
            self.getStartedButton.isHidden = true
            self.learnMoreButton.isHidden = true
            self.imageView.image = UIImage(named: "carousel_globe")
            
        case .connect:
            self.titleLabel.text = LocalizedString.connectTitle.value
            self.subtitleLabel.text = LocalizedString.connectSubtitle.value
            self.learnMoreButton.isHidden = true
            self.imageView.image = UIImage(named: "carousel_meter")
            OnboardingViewController.navigableItem = .getStarted
            //move getStartedButton down
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
    case activityLogs
    case encryption
    case countries
    case connect
}
