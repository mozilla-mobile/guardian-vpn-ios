//
//  NSAttributedString+Extensions
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

extension NSAttributedString {
    static func formattedError(_ error: GuardianAppError, canTryAgain: Bool = true) -> NSAttributedString {
        return formatted(error.description, actionMessage: canTryAgain ? LocalizedString.toastTryAgain.value : nil)
    }

    static func formatted(_ message: String, actionMessage: String?) -> NSAttributedString {
        let message = NSMutableAttributedString(string: message)
        if let selectMessage = actionMessage {
            let underlinedMessage = NSAttributedString(string: selectMessage, attributes: [
                .font: UIFont.custom(.interSemiBold, size: 13),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ])
            message.append(NSAttributedString(string: " "))
            message.append(underlinedMessage)
        }
        return message
    }
}
