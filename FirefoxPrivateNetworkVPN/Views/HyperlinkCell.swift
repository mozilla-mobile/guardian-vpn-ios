//
//  HyperlinkCell
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
