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
    static let height: CGFloat = 175.0

    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appDescriptionLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!

    override func awakeFromNib() {
        appNameLabel.text = LocalizedString.aboutAppName.value
        appDescriptionLabel.text = LocalizedString.aboutDescription.value
        releaseLabel.text = LocalizedString.aboutReleaseVersion.value
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
