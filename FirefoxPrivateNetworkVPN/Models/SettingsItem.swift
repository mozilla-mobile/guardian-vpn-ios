//
//  SettingsItem
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

enum SettingsItem: Equatable {
    case device
    case help
    case about
    case feedback
    case signout
    case account

    var title: String {
        switch self {
        case .device: return LocalizedString.settingsItemDevices.value
        case .help: return LocalizedString.settingsItemHelp.value
        case .about: return LocalizedString.settingsItemAbout.value
        case .feedback: return LocalizedString.settingsFeedback.value
        case .signout: return LocalizedString.settingsSignOut.value
        case .account: return LocalizedString.settingsManageAccount.value
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .device: return #imageLiteral(resourceName: "icon_device")
        case .help: return #imageLiteral(resourceName: "icon_help")
        case .about: return #imageLiteral(resourceName: "icon_about")
        case .feedback: return #imageLiteral(resourceName: "icon_smile")
        case .signout, .account: return nil
        }
    }

    var disclosureImage: UIImage? {
        switch self {
        case .feedback: return #imageLiteral(resourceName: "icon_openIn.pdf")
        default: return #imageLiteral(resourceName: "icon_forwardChevron.pdf")
        }
    }

    var navigableItem: NavigableItem? {
        switch self {
        case .device: return .devices
        case .help: return .help
        case .about: return .about
        case .feedback, .account: return .safari
        case .signout: return nil
        }
    }

    var navigableContext: NavigableContext? {
        switch self {
        case .feedback: return .url(FirefoxURL.feedback.value)
        case .account: return .url(FirefoxURL.account.value)
        case .device, .about, .help, .signout: return nil
        }
    }
}
