//
//  NSTextAttachment+Extensions
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

extension NSTextAttachment {

    func centerImage(with label: UILabel) {
        guard let image = image else { return }

        bounds = CGRect(x: 0, y: (label.font.capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
    }
}
