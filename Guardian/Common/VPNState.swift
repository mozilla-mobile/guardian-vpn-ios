// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import NetworkExtension

enum VPNState {
    case on
    case off
    case connecting
    case switching
    case disconnecting

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
            return UIColor.guardianGrey
        default:
            return UIColor.white
        }
    }

    var title: String {
        switch self {
        case .off:
            return "VPN is off"
        case .connecting:
            return "Connecting"
        case .on:
            return "VPN is on"
        case .switching:
            return "Switching"
        case .disconnecting:
            return "Disconnecting…"
        }
    }

    var subtitle: String {
        switch self {
        case .off:
            return "Turn it on to protect your entire device"
        case .connecting, .switching:
            return "You will be protected shortly"
        case .on:
            return "Secure and protected"
        case .disconnecting:
            return "You will be disconnected shortly"
        }
    }

    var globeImage: UIImage? {
        switch self {
        case .off:
            return #imageLiteral(resourceName: "globe_off")
        case .connecting:
            return #imageLiteral(resourceName: "globe_connecting")
        case .on:
            return #imageLiteral(resourceName: "globe_on")
        case .switching, .disconnecting:
            return #imageLiteral(resourceName: "globe_disconnecting")
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .off, .disconnecting, .switching:
            return UIColor.white
        default:
            return UIColor.backgroundPurple
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

    var delay: TimeInterval? {
        switch self {
        case .connecting, .disconnecting:
            return 1
        case .switching:
            return 1.5
        default:
            return nil
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
