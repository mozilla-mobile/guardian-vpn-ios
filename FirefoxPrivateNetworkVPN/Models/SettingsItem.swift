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

enum SettingsItem {
    case device
    case help
    case about
    case feedback
    case signout

    var title: String {
        switch self {
        case .device: return LocalizedString.settingsItemDevices.value
        case .help: return LocalizedString.settingsItemHelp.value
        case .about: return LocalizedString.settingsItemAbout.value
        case .feedback: return LocalizedString.settingsFeedback.value
        case .signout: return LocalizedString.settingsSignOut.value
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .device: return #imageLiteral(resourceName: "icon_device")
        case .help: return #imageLiteral(resourceName: "icon_help")
        case .about: return #imageLiteral(resourceName: "icon_about")
        case .feedback: return #imageLiteral(resourceName: "icon_bug.pdf")
        default: return nil
        }
    }

    var disclosureImage: UIImage? {
        switch self {
        case .feedback: return #imageLiteral(resourceName: "icon_openIn.pdf")
        default: return #imageLiteral(resourceName: "icon_forwardChevron.pdf")
        }
    }

    var action: NavigableItem? {
        switch self {
        case .device: return .devices
        case .help: return .help
        case .about: return .about
        case .feedback: return .hyperlink(FirefoxURL.feedback.value)
        case .signout: return nil
        }
    }
}
