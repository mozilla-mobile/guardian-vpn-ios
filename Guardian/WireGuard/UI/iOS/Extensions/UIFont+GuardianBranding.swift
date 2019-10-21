// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

/**
 Metropolis Font names: ["Metropolis-Bold", "Metropolis-Regular", "Metropolis-MediumItalic", "Metropolis-SemiBoldItalic", "Metropolis-RegularItalic", "Metropolis-ThinItalic", "Metropolis-ExtraLightItalic", "Metropolis-ExtraBold", "Metropolis-LightItalic", "Metropolis-BoldItalic", "Metropolis-Thin", "Metropolis-Medium", "Metropolis-SemiBold", "Metropolis-ExtraBoldItalic", "Metropolis-Black", "Metropolis-BlackItalic", "Metropolis-ExtraLight", "Metropolis-Light"]

 ["Inter-Medium", "Inter-SemiBold", "Inter-Regular"]
 */

extension UIFont {
    // MARK: Common
    static var navigationTitleFont: UIFont {
        return titleMetropolisFont
    }

    // MARK: VPN Screen
    static var vpnTitleFont: UIFont {
        return UIFont(name: "Metropolis", size: 22)!
    }

    static var vpnSubtitleFont: UIFont {
        return regularInterFont
    }

    static var vpnSelectorTitleFont: UIFont {
        return regularInterFont
    }

    static var vpnSelectConnectionFont: UIFont {
        return UIFont(name: "Inter", size: 11)!
    }

    // MARK: Connection Screen
    static var connectionCityCellFont: UIFont {
        return regularInterFont
    }

    static var connectionCountryFont: UIFont {
        return titleMetropolisFont
    }

    // MARK: Base Fonts
    private static var regularInterFont: UIFont {
        return UIFont(name: "Inter", size: 15)!
    }

    private static var titleMetropolisFont: UIFont {
        return UIFont(name: "Metropolis-SemiBold", size: 15)!
    }
}
