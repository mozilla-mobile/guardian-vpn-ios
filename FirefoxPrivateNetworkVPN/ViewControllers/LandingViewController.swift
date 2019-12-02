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

class LandingViewController: OnboardingViewController, Navigating {
    static var navigableItem: NavigableItem = .landing

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func getStarted() {
        navigate(to: .login)
    }

    override func learnMore() {
        navigate(to: .carousel)
    }

    private func setupView() {
        titleLabel.text = LocalizedString.landingTitle.value
        subtitleLabel.text = LocalizedString.landingSubtitle.value
        getStartedButton.setTitle(LocalizedString.getStarted.value, for: .normal)
        learnMoreButton.setTitle(LocalizedString.learnMore.value, for: .normal)
        imageView.image = UIImage(named: "logo")
    }
}
