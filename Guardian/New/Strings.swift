//
//  Strings
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

enum LocalizableString: String {
    case settingsTabName
    case settingsItemDevices
    case settingsItemHelp
    case settingsItemAbout

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
}

extension String {
    init(_ string: LocalizableString) {
        self.init(string.rawValue)
    }
}
