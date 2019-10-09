// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

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
        title.text = "Device limit reached"
        subtitle.text = "Please remove 1 device below to use Private Network on this device"
    }
}
