//
//  AboutHeaderView
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
