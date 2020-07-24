//
//  UIFont+Custom
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

enum CustomFont: String {
    case metropolis = "Metropolis"
    case metropolisSemiBold = "Metropolis-SemiBold"
    case interSemiBold = "Inter-SemiBold"
    case inter = "Inter"
}

#if os(iOS)

import UIKit

extension UIFont {
    static func custom(_ font: CustomFont, size: CGFloat = 15) -> UIFont {
        return UIFont(name: font.rawValue, size: size)!
    }
}

#elseif os(macOS)

import AppKit

extension NSFont {
    static func custom(_ font: CustomFont, size: CGFloat = 15) -> NSFont {
        return NSFont(name: font.rawValue, size: size)!
    }
}

#endif
