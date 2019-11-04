//
//  VPNState
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

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
            return UIColor.custom(.grey50)
        default:
            return UIColor.white
        }
    }

    var title: String {
        switch self {
        case .off:
            return String(.Home_Title_Off)
        case .connecting:
            return String(.Home_Title_Connecting)
        case .on:
            return String(.Home_Title_On)
        case .switching:
            return String(.Home_Title_Switching)
        case .disconnecting:
            return String(.Home_Title_Disconnecting)
        }
    }

    var subtitle: String {
        switch self {
        case .off:
            return String(.Home_Subtitle_Off)
        case .connecting, .switching:
            return String(.Home_Subtitle_Connecting)
        case .on:
            return String(.Home_Subtitle_On)
        case .disconnecting:
            return String(.Home_Subtitle_Disconnecting)
        }
    }

    var globeImage: UIImage? {
        switch self {
        case .off, .switching, .disconnecting:
            return #imageLiteral(resourceName: "globe_off")
        case .on, .connecting:
            return #imageLiteral(resourceName: "globe_on")
        }
    }
    
    var globeOpacity: CGFloat {
        switch self {
        case .off, .on:
            return 1.0
        case .connecting, .switching, .disconnecting:
            return 0.5
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
