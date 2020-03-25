//
//  UpdateRecommendedViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

class UpdateRequiredViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .requiredUpdate

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var connectionSubtitleLabel: UILabel!
    @IBOutlet weak var updateNowButton: UIButton!
    @IBOutlet weak var manageAccountButton: UIButton!
    @IBOutlet weak var signoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setLocalizedStrings()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        setupButton()
    }

    @IBAction func updateNowTapped() {
        navigate(to: .appStore)
    }

    @IBAction func manageAccountTapped() {
        navigate(to: .hyperlink(HyperlinkItem.account.url))
    }

    @IBAction func signoutTapped() {
        DependencyFactory.sharedFactory.accountManager.logout { [weak self] _ in
            self?.navigate(to: .landing())
        }
    }

    // MARK: - Setup
    private func setLocalizedStrings() {
        titleLabel.text = LocalizedString.updateRequired.value
        subtitleLabel.text = LocalizedString.updateRequiredSubtitle.value
        connectionSubtitleLabel.text = LocalizedString.updateConnection.value
        updateNowButton.titleLabel?.text = LocalizedString.updateNow.value
        manageAccountButton.titleLabel?.text = LocalizedString.settingsManageAccount.value
        signoutButton.titleLabel?.text = LocalizedString.settingsSignOut.value
    }

    private func setupButton() {
        updateNowButton.setBackgroundImage(UIImage.image(with: UIColor.custom(.blue80)), for: .highlighted)
        updateNowButton.cornerRadius = updateNowButton.frame.height/10
    }
}
