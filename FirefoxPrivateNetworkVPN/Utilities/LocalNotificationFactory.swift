//
//  LocalNotificationFactory
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation
import UserNotifications

struct LocalNotificationFactory {

    enum LocalNotificationOption {
        case vpnConnected
        case vpnDisconnected
        case vpnSwitched(String)
        case vpnUnstable
        case vpnNoSignal

        private var title: String {
            switch self {
            case .vpnConnected:
                return LocalizedString.notificationTitleOn.value
            case .vpnDisconnected:
                return LocalizedString.notificationTitleOff.value
            case .vpnSwitched(let title):
                return title
            case .vpnUnstable:
                return LocalizedString.notificationTitleUnstable.value
            case .vpnNoSignal:
                return LocalizedString.notificationTitleNoSignal.value
            }
        }

        private var body: String {
            switch self {
            case .vpnConnected:
                return LocalizedString.notificationBodyOn.value
            case .vpnDisconnected:
                return LocalizedString.notificationBodyOff.value
            case .vpnSwitched:
                return LocalizedString.notificationBodySwitched.value
            case .vpnUnstable:
                return LocalizedString.notificationBodyUnstable.value
            case .vpnNoSignal:
                return LocalizedString.notificationBodyNoSignal.value
            }
        }

        private var sound: UNNotificationSound? { .default }

        private var attachments: [UNNotificationAttachment] {
            switch self {
            case .vpnUnstable:
                // TODO: update image URL
                guard let imageURL: URL = Bundle.main.url(forResource: "Error", withExtension: "png"),
                    let attachment = try? UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil) else {
                    return []
                }
                return [attachment]
            case .vpnNoSignal:
                // TODO: update image URL
                guard let imageURL: URL = Bundle.main.url(forResource: "Error", withExtension: "png"),
                    let attachment = try? UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil) else {
                    return []
                }
                return [attachment]
            default:
                return []
            }
        }

        private var identifier: String {
            switch self {
            case .vpnConnected:
                return "onNotification"
            case .vpnDisconnected:
                return "offNotification"
            case .vpnSwitched:
                return "switchedNotification"
            case .vpnUnstable:
                return "unstableNotification"
            case .vpnNoSignal:
                return "noSignalNotification"
            }
        }

        private var trigger: UNNotificationTrigger? { nil }

        var request: UNNotificationRequest {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = sound
            content.attachments = attachments
            return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        }
    }

    static func showNotification(when option: LocalNotificationOption) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional) else { return }
            center.add(option.request, withCompletionHandler: nil)
        }
    }
}
