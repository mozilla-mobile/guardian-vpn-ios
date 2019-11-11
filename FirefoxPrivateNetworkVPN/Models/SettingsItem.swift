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

    var title: String {
        switch self {
        case .device: return LocalizedString.settingsItemDevices.value
        case .help: return LocalizedString.settingsItemHelp.value
        case .about: return LocalizedString.settingsItemAbout.value
        }
    }

    var image: UIImage? {
        switch self {
        case .device: return #imageLiteral(resourceName: "icon_device")
        case .help: return #imageLiteral(resourceName: "icon_help")
        case .about: return #imageLiteral(resourceName: "icon_about")
        }
    }

    var action: NavigableItem {
        switch self {
        case .device: return .devices
        case .help: return .help
        case .about: return .about
        }
    }
}
