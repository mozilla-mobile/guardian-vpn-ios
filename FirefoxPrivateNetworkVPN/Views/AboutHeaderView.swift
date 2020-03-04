//
//  AboutHeaderView
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class AboutHeaderView: UITableViewHeaderFooterView {
    static let height: CGFloat = UIScreen.isiPad ? 224.0 : 175.0

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appDescriptionLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!

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
