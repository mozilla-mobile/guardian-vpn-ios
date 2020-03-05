//
//  EmailManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import MessageUI

class EmailManager: NSObject, MFMailComposeViewControllerDelegate {
    private let supportEmailAddress = "firefox-team@mozilla.com"
    private let logsFileName = "debug_logs"
    private let logsMimeType = "text/strings"
    private var account: Account? { return DependencyFactory.sharedFactory.accountManager.account }

    private var logsSubject: String {
        let username = account?.user?.displayName ?? ""
        let email = account?.user?.email ?? ""

        return LocalizedString.logsMailSubject.value + "\(username)/\(email)"
    }

    private var logsBody: String {
        return LocalizedString.logsMailBody.value + "\n\n\(deviceInfo)"
    }

    private var deviceInfo: String {
        let name = account?.currentDevice?.name ?? ""
        let key = account?.currentDevice?.publicKey ?? ""

        let deviceName = LocalizedString.logsMailDeviceName.value + name
        let publicKey = LocalizedString.logsMailDeviceKey.value + key

        var createdDate = LocalizedString.logsMailDeviceDate.value
        if let date = account?.currentDevice?.createdAtDate {
            createdDate.append(String(describing: date))
        }

        return deviceName + "\n" + createdDate + "\n" + publicKey
    }

    func getMailWithDebugLogs() -> MFMailComposeViewController? {
        guard MFMailComposeViewController.canSendMail(),
            let attachment = FileManager.logsAsData
            else { return nil }

        let mail = MFMailComposeViewController()
        mail.setToRecipients([supportEmailAddress])
        mail.setSubject(logsSubject)
        mail.setMessageBody(logsBody, isHTML: false)

        mail.addAttachmentData(attachment,
                               mimeType: logsMimeType,
                               fileName: logsFileName)

        return mail
    }
}
