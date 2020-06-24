//
//  CarouselViewType
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

enum CarouselViewType {
    case noLogs
    case encryption
    case manyServers
    case noRestrictions

    var title: String {
        switch self {
        case .noLogs:
            return LocalizedString.noLogsTitle.value
        case .encryption:
            return LocalizedString.encryptionTitle.value
        case .manyServers:
            return LocalizedString.manyServersTitle.value
        case .noRestrictions:
            return LocalizedString.noRestrictionsTitle.value
        }
    }

    var subtitle: String {
        switch self {
        case .noLogs:
            return LocalizedString.noLogsSubtitle.value
        case .encryption:
            return LocalizedString.encryptionSubtitle.value
        case .manyServers:
            return LocalizedString.manyServersSubtitle.value
        case .noRestrictions:
            return LocalizedString.noRestrictionsSubtitle.value
        }
    }

    var image: UIImage? {
        switch self {
        case .noLogs:
            return UIImage(named: "carousel_padlock")
        case .encryption:
            return UIImage(named: "carousel_encryption")
        case .manyServers:
            return UIImage(named: "carousel_globe")
        case .noRestrictions:
            return UIImage(named: "carousel_meter")
        }
    }
}
