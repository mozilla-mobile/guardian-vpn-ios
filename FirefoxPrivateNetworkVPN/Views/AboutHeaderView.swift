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
//        appNameLabel.text = LocalizedString.aboutAppName.value
//        appNameLabel.font = UIFont.custom(.metropolisSemiBold, size: 15)
//        appNameLabel.textColor = UIColor.custom(.grey50)

        appNameLabel.setupText(title: LocalizedString.aboutAppName.value,
                               lineHeightMultiple: 1.6,
                               font: UIFont.custom(.metropolisSemiBold, size: 15),
                               color: UIColor.custom(.grey50))

//        appDescriptionLabel.text = LocalizedString.aboutDescription.value
//        appDescriptionLabel.font = UIFont.custom(.inter, size: 13)
//        appDescriptionLabel.textColor = UIColor.custom(.grey40)

        appDescriptionLabel.setupText(title: LocalizedString.aboutDescription.value,
                                      lineHeightMultiple: 1.33,
                                      font: UIFont.custom(.inter, size: 13),
                                      color: UIColor.custom(.grey40))

//        releaseLabel.text = LocalizedString.aboutReleaseVersion.value
//        releaseLabel.font = UIFont.custom(.metropolisSemiBold, size: 15)
//        releaseLabel.textColor = UIColor.custom(.grey50)

        releaseLabel.setupText(title: LocalizedString.aboutAppName.value,
                               lineHeightMultiple: 1.6,
                               font: UIFont.custom(.metropolisSemiBold, size: 15),
                               color: UIColor.custom(.grey50))

//        versionLabel.text = UIApplication.appVersion
//        versionLabel.font = UIFont.custom(.inter, size: 13)
//        versionLabel.textColor = UIColor.custom(.grey40)

        versionLabel.setupText(title: LocalizedString.aboutAppName.value,
                               lineHeightMultiple: 1.33,
                               font: UIFont.custom(.inter, size: 13),
                               color: UIColor.custom(.grey40))
    }
}

extension UILabel {
    func setupText(title: String, lineHeightMultiple: CGFloat, font: UIFont, color: UIColor) {
        let attributedString = NSMutableAttributedString(string: title)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedDict = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                              NSAttributedString.Key.font: font,
                              NSAttributedString.Key.foregroundColor: color]

        attributedString.addAttributes(attributedDict, range:NSMakeRange(0, attributedString.length))

        attributedText = attributedString
    }
}
