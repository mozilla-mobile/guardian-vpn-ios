// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import NetworkExtension

enum VPNState {
    case on
    case off
    case connecting
    case switching

    init(with status: NEVPNStatus) {
        switch status {
        case .invalid, .disconnected, .disconnecting:
            self = .off
        case .connecting, .reasserting:
            self = .connecting
        case .connected:
            self = .on
        default:
            self = .off
        }
    }
}

extension VPNState {
    var textColor: UIColor {
        switch self {
        case .off, .switching:
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
        }
    }

    var globeImage: UIImage? {
        switch self {
        case .off:
            return UIImage(named: "globe_off")
        case .connecting:
            return UIImage(named: "globe_connecting")
        case .on:
            return UIImage(named: "globe_on")
        case .switching:
            return UIImage(named: "globe_switching")
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .off, .switching:
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
        case .on, .connecting, .switching:
            return true
        default:
            return false
        }
    }

    var delay: TimeInterval? {
        switch self {
        case .connecting:
            return 1
        case .switching:
            return 1.5
        default:
            return nil
        }
    }
}
