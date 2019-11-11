//
//  HyperlinkCell
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class HyperlinkCell: UITableViewCell {
    static let height: CGFloat = 56.0

    var item: HyperlinkItem?

    @IBOutlet weak var titleLabel: UILabel!

    func setup(as item: HyperlinkItem) {
        self.item = item
        titleLabel.text = item.title
    }
}
