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

    static let height: CGFloat = 252.0

    override func awakeFromNib() {
        super.awakeFromNib()
        styleViews()
    }

    private func styleViews() {
        title.text = "Remove a device"
        // TODO: Figure out how many devices they need to remove based on max devices in JSON response
        subtitle.text = "You've reached your limit. To install the VPN on this device, you'll need to remove one."
        backgroundView = UIView()
        backgroundView?.backgroundColor = .white
    }
}
