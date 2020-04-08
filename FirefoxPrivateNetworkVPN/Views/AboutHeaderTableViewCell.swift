//
//  AboutHeaderTableViewCell
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

class AboutHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak private var appNameLabel: UILabel!
    @IBOutlet weak private var appDescriptionLabel: UILabel!
    @IBOutlet weak private var releaseLabel: UILabel!
    @IBOutlet weak private var versionLabel: UILabel!

    static let estimatedHeight: CGFloat = UIScreen.isiPad ? 224.0 : 175.0

    override func awakeFromNib() {
        super.awakeFromNib()

        setupLabels()
    }

    private func setupLabels() {
        appNameLabel.setAttributedText(title: LocalizedString.aboutAppName.value,
                                       lineHeightMultiple: 1.6,
                                       font: UIFont.custom(.metropolisSemiBold, size: 15),
                                       color: UIColor.custom(.grey50))

        appDescriptionLabel.setAttributedText(title: LocalizedString.landingSubtitle.value,
                                              lineHeightMultiple: 1.33,
                                              font: UIFont.custom(.inter, size: 13),
                                              color: UIColor.custom(.grey40))

        releaseLabel.setAttributedText(title: LocalizedString.aboutReleaseVersion.value,
                                       lineHeightMultiple: 1.6,
                                       font: UIFont.custom(.metropolisSemiBold, size: 15),
                                       color: UIColor.custom(.grey50))

        versionLabel.setAttributedText(title: UIApplication.appVersion,
                                       lineHeightMultiple: 1.33,
                                       font: UIFont.custom(.inter, size: 13),
                                       color: UIColor.custom(.grey40))
    }
}
