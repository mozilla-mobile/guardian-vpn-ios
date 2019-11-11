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

class LandingViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .landing

    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setStrings()
    }

    private func setStrings() {
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = LocalizedString.landingTitle.value
            self?.subtitleLabel.text = LocalizedString.landingSubtitle.value
            self?.getStartedButton.setTitle(LocalizedString.landingGetStarted.value, for: .normal)
            self?.learnMoreButton.setTitle(LocalizedString.landingLearnMore.value, for: .normal)
        }
    }

    @IBAction func getStarted() {
        navigate(to: .login)
    }

    @IBAction func learnMore() {
        navigate(to: .carousel)
    }
}
