//
//  ConnectionState
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

enum ConnectionHealth {
    case initial, stable, unstable, noSignal
}

extension ConnectionHealth {
    var icon: UIImage? {
        switch self {
        case .unstable:
            return UIImage(named: "icon_unstable")
        case .noSignal:
            return UIImage(named: "icon_nosignal")
        default:
            return nil
        }
    }

    var subtitleText: String {
        switch self {
        case .unstable:
            return LocalizedString.homeSubtitleUnstable.value
        case .noSignal:
            return LocalizedString.homeSubtitleNoSignal.value
        default:
            return LocalizedString.homeSubtitleOn.value
        }
    }

    var textColor: UIColor {
        switch self {
        case .unstable:
            return UIColor.custom(.yellow50)
        case .noSignal:
            return UIColor.custom(.red50)
        default:
            return UIColor.custom(.white80)
        }
    }
}
