//
//  CarouselViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class CarouselViewController: OnboardingViewController, Navigating {
    static var navigableItem: NavigableItem = .carousel

    var type: CarouselViewType

    init(for type: CarouselViewType) {
        self.type = type
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        imageView.image = type.image
        titleLabel.text = type.title
        subtitleLabel.text = type.subtitle

        switch type {
        case .getStarted:
            learnMoreButton.removeFromSuperview()
            getStartedButton.setTitle(LocalizedString.getStarted.value, for: .normal)
            buttonStackViewBottomConstraint.constant = 48

        default:
            buttonStackView.isHidden = true
        }
    }

    override func getStarted() {
        navigate(to: .login)
    }
}
