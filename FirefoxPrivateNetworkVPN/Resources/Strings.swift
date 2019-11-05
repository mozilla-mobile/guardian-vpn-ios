//
//  Strings
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

enum LocalizedString: String {
    case landingTitle
    case landingSubtitle
    case landingGetStarted
    case landingLearnMore

    case homeTabName

    case homeTitleOff
    case homeTitleConnecting
    case homeTitleOn
    case homeTitleSwitching
    case homeTitleDisconnecting

    case homeSubtitleOff
    case homeSubtitleConnecting
    case homeSubtitleOn
    case homeSubtitleSwitching
    case homeSubtitleDisconnecting
    case homeSubtitleCheckConnection
    case homeSubtitleUnstable
    case homeSubtitleNoSignal

    case homeApplicationName
    case homeSelectConnection

    case serversNavTitle

    case settingsTabName
    case settingsItemDevices
    case settingsItemHelp
    case settingsItemAbout
    case settingsSignOut

    case settingsDefaultName
    case settingsManageAccount

    case devicesNavTitle
    case devicesCount
    case devicesCurrentDevice
    case devicesAddedDate

    var value: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
