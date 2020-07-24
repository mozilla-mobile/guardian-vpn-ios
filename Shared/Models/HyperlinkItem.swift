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

enum HyperlinkItem: Equatable {
    case contact
    case support
    case terms
    case privacy
    case account(email: String?)
    case debug

    var title: String {
        switch self {
        case .contact: return LocalizedString.helpContactUs.value
        case .support: return LocalizedString.helpSupport.value
        case .terms: return LocalizedString.aboutTerms.value
        case .privacy: return LocalizedString.aboutPrivacy.value
        case .account: return LocalizedString.settingsManageAccount.value
        case .debug: return LocalizedString.helpDebug.value
        }
    }

    var url: URL? {
        switch self {
        case .contact: return FirefoxURL.contact.value
        case .support: return FirefoxURL.support.value
        case .terms: return FirefoxURL.terms.value
        case .privacy: return FirefoxURL.privacy.value
        case .account(let email): return FirefoxURL.account(email: email).value
        case .debug: return nil
        }
    }
}
