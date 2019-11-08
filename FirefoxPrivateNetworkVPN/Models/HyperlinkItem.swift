//
//  HyperlinkItem
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

enum HyperlinkItem {
    case contact
    case support
    case terms
    case privacy

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
            // <guardian_base>/r/vpn/contact?utm_medium=fx-vpn&utm_source=fx-vpn-iOSs&utm_campaign=download-client
            return URL(string: "https://support.mozilla.org/")
        case .support:
            // https://support.mozilla.org/1/vpn/1.0b/Windows/en-US/vpn?utm_medium=fx-vpn&utm_source=fx-vpn-iOS&utm_campaign=download-client
            return URL(string: "https://support.mozilla.org/")
        case .terms:
            // /r/vpn/terms
            return URL(string: "https://support.mozilla.org/")
        case .privacy:
            // /r/vpn/privacy
            return URL(string: "https://support.mozilla.org/")
        }
    }
}
