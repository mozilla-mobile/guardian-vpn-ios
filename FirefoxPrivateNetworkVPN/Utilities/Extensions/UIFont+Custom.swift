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

import UIKit

enum CustomFont: String {
    case metropolis = "Metropolis"
    case metropolisSemiBold = "Metropolis-SemiBold"
    case interSemiBold = "Inter-SemiBold"
    case inter = "Inter"
}

extension UIFont {
    static func custom(_ font: CustomFont, size: CGFloat = 15) -> UIFont {
        return UIFont(name: font.rawValue, size: size)!
    }
}
