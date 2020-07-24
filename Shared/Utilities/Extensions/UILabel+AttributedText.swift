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

#if os(iOS)

import UIKit

extension UILabel {
    func setAttributedText(title: String, lineHeightMultiple: CGFloat, alignment: NSTextAlignment = .left, font: UIFont, color: UIColor) {
        let attributedString = NSMutableAttributedString(string: title)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = alignment

        let attributedDict = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                              NSAttributedString.Key.font: font,
                              NSAttributedString.Key.foregroundColor: color]

        //swiftlint:disable legacy_constructor
        attributedString.addAttributes(attributedDict,
                                       range: NSMakeRange(0, attributedString.length))

        attributedText = attributedString
    }
}

#elseif os(macOS)

import AppKit

extension NSTextField {
    func setAttributedText(title: String, lineHeightMultiple: CGFloat, font: NSFont, color: NSColor) {
        let attributedString = NSMutableAttributedString(string: title)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedDict = [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                              NSAttributedString.Key.font: font,
                              NSAttributedString.Key.foregroundColor: color]

        //swiftlint:disable legacy_constructor
        attributedString.addAttributes(attributedDict,
                                       range: NSMakeRange(0, attributedString.length))

        attributedStringValue = attributedString
    }
}

#endif
