//
//  VPNState
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import NetworkExtension

enum VPNState {
    case on
    case off
    case connecting
    case switching(String, String)
    case disconnecting
    case error(TunnelError)

    init(with status: NEVPNStatus) {
        switch status {
        case .invalid, .disconnected:
            self = .off
        case .connecting, .reasserting:
            self = .connecting
        case .connected:
            self = .on
        case .disconnecting:
            self = .disconnecting
        default:
            self = .off
        }
    }
}

extension VPNState {
    var textColor: UIColor {
        switch self {
        case .off, .switching, .disconnecting:
            return UIColor.custom(.grey50)
        default:
            return UIColor.white
        }
    }

    var subtitleColor: UIColor {
        switch self {
        case .off, .switching, .disconnecting:
            return UIColor.custom(.grey40)
        default:
            return UIColor.custom(.white80)
        }
    }

    var title: String {
        switch self {
        case .off:
            return LocalizedString.homeTitleOff.value
        case .connecting:
            return LocalizedString.homeTitleConnecting.value
        case .on:
            return LocalizedString.homeTitleOn.value
        case .switching:
            return LocalizedString.homeTitleSwitching.value
        case .disconnecting:
            return LocalizedString.homeTitleDisconnecting.value
        default: return ""
        }
    }

    var subtitle: String {
        switch self {
        case .off:
            return LocalizedString.homeSubtitleOff.value
        case .connecting:
            return LocalizedString.homeSubtitleConnecting.value
        case .switching(let fromCity, let toCity):
            return String(format: LocalizedString.homeSubtitleSwitching.value, fromCity, toCity)
        case .on:
            return ""
        case .disconnecting:
            return LocalizedString.homeSubtitleDisconnecting.value
        default: return ""
        }
    }

    var globeOpacity: CGFloat {
        switch self {
        case .off, .on:
            return 1.0
        case .connecting, .switching, .disconnecting:
            return 0.5
        default: return 1.0
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .off, .disconnecting, .switching:
            return UIColor.white
        default:
            return UIColor.custom(.purple90)
        }
    }

    var showActivityIndicator: Bool {
        switch self {
        case .connecting:
            return true
        default:
            return false
        }
    }

    var isToggleOn: Bool {
        switch self {
        case .on, .connecting:
            return true
        default:
            return false
        }
    }

    var isEnabled: Bool {
        switch self {
        case .connecting, .disconnecting, .switching:
            return false
        default:
            return true
        }
    }
}

extension VPNState: Equatable { }
