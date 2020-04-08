//
//  DeviceLimitReachedView
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class DeviceLimitReachedView: UITableViewHeaderFooterView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!

    static let height: CGFloat = UIScreen.isiPad ? 316.0 : 274.0

    override func awakeFromNib() {
        super.awakeFromNib()
        styleViews()
    }

    private func styleViews() {
        title.text = LocalizedString.devicesLimitTitle.value
        title.font = UIFont.custom(.metropolis, size: 22)
        title.textColor = UIColor.custom(.grey50)
        subtitle.text = LocalizedString.devicesLimitSubtitle.value
        subtitle.font = UIFont.custom(.inter)
        subtitle.textColor = UIColor.custom(.grey40)
        let customBackgroundView = UIView()
        customBackgroundView.backgroundColor = UIColor.custom(.grey5)
        backgroundView = customBackgroundView
    }
}
