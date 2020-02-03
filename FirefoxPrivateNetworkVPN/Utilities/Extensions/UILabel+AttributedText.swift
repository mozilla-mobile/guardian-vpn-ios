//
//  UILabel+AttributedText
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

extension UILabel {
    func setAttributedText(title: String, lineHeightMultiple: CGFloat, font: UIFont, color: UIColor) {
        let attributedString = NSMutableAttributedString(string: title)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedDict = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                              NSAttributedString.Key.font: font,
                              NSAttributedString.Key.foregroundColor: color]

        //swiftlint:disable legacy_constructor
        attributedString.addAttributes(attributedDict,
                                       range: NSMakeRange(0, attributedString.length))

        attributedText = attributedString
    }
}
