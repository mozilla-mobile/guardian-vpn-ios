//
//  NotificationViewController
//  NotificationContentExtension
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: view.bounds.width, height: 30)
    }

    func didReceive(_ notification: UNNotification) {
        if let attachment = notification.request.content.attachments.first {
            if attachment.url.startAccessingSecurityScopedResource() {
                if let data = try? Data(contentsOf: attachment.url) {
                    imageView.image = UIImage(data: data)
                }
                attachment.url.stopAccessingSecurityScopedResource()
            }
        }
    }

}
