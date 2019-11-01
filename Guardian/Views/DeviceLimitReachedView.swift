// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

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
