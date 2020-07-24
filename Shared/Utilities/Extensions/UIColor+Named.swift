//
//  UIColor+Named
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

enum CustomColor: String {
    case blue50 = "custom_blue50"
    case blue60 = "custom_blue60"
    case blue80 = "custom_blue80"
    case buttonHighlight = "custom_buttonHighlight"
    case green50 = "custom_green50"
    case grey5 = "custom_grey5"
    case grey10 = "custom_grey10"
    case grey20 = "custom_grey20"
    case grey30 = "custom_grey30"
    case grey40 = "custom_grey40"
    case grey50 = "custom_grey50"
    case launch = "custom_launch"
    case purple90 = "custom_purple90"
    case red40  = "custom_red40"
    case red50 = "custom_red50"
    case silver = "custom_silver"
    case yellow50 = "custom_yellow50"
    case white80 = "custom_white80"
}

#if os(iOS)

import UIKit

extension UIColor {
    static func custom(_ color: CustomColor) -> UIColor {
        // Must correspond with named colors in Assets.xcassets
        return UIColor(named: color.rawValue)!
    }
}

#elseif os(macOS)

import AppKit

extension NSColor {
    static func custom(_ color: CustomColor) -> NSColor {
        // Must correspond with named colors in Assets.xcassets
        return NSColor(named: color.rawValue)!
    }
}

#endif
