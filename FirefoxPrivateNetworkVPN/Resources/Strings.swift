//
//  Strings
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

enum LocalizedString: String {
    case landingTitle
    case landingSubtitle
    case noLogsTitle
    case noLogsSubtitle
    case encryptionTitle
    case encryptionSubtitle
    case manyServersTitle
    case manyServersSubtitle
    case noRestrictionsTitle
    case noRestrictionsSubtitle
    case getStarted
    case learnMore
    case landingSkip

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
    case homeSubtitleWeek
    case homeSubtitleWeekPlus

    case homeApplicationName
    case homeSelectConnection

    case serversNavTitle

    case settingsTabName
    case settingsItemDevices
    case settingsItemHelp
    case settingsItemAbout
    case settingsSignOut
    case settingsFeedback
    case settingsPurchase

    case settingsDefaultName
    case settingsManageAccount

    case devicesNavTitle
    case devicesCount
    case devicesCurrentDevice
    case devicesAddedDate
    case devicesLimitTitle
    case devicesLimitSubtitle
    case devicesConfirmDeletionTitle
    case devicesConfirmDeletionMessage
    case devicesConfirmDeletion
    case devicesCancelDeletion

    case helpTitle
    case helpContactUs
    case helpSupport
    case helpDebug

    case aboutTitle
    case aboutTerms
    case aboutPrivacy
    case aboutAppName
    case aboutAppDescription
    case aboutReleaseVersion

    case toastTryAgain
    case toastLoggedOut
    case toastNoConnection
    case toastAuthenticationError

    case toastFeaturesAvailable

    case updateNow
    case updateConnection

    case updateRecommended
    case updateRecommendedSubtitle

    case updateRequired
    case updateRequiredSubtitle

    case errorDeviceRemoval
    case errorConnectVPN

    case logsFileName
    case logsMailSubject
    case logsMailBody
    case logsMailDeviceName
    case logsMailDeviceDate
    case logsMailDeviceKey

    case notificationTitleOn
    case notificationBodyOn
    case notificationTitleOff
    case notificationBodyOff
    case notificationBodySwitched
    case notificationTitleUnstable
    case notificationBodyUnstable
    case notificationTitleNoSignal
    case notificationBodyNoSignal

    var value: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
