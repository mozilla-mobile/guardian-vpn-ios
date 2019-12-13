//
//  HyperlinkItem
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

enum HyperlinkItem {
    case contact
    case support
    case terms
    case privacy

    private static let base = "https://fpn.firefox.com"
    private static let query = "?utm_medium=fx-vpn&utm_source=fx-vpn-iOSs&utm_campaign=download-client"

    var title: String {
        switch self {
        case .contact: return LocalizedString.helpContactUs.value
        case .support: return LocalizedString.helpSupport.value
        case .terms: return LocalizedString.aboutTerms.value
        case .privacy: return LocalizedString.aboutPrivacy.value
        }
    }

    var url: URL? {
        switch self {
        case .contact:
            return URL(string: HyperlinkItem.base + "/r/vpn/contact" + HyperlinkItem.query)
        case .support:
            // TODO: change support url when it's available
            return URL(string: "https://support.mozilla.org/")
        case .terms:
            return URL(string: HyperlinkItem.base + "/r/vpn/terms" + HyperlinkItem.query)
        case .privacy:
            return URL(string: HyperlinkItem.base + "/r/vpn/privacy" + HyperlinkItem.query)
        }
    }
}
