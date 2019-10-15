// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class CountryVPNHeaderView: UITableViewHeaderFooterView {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var backdropView: UIView!
    @IBOutlet var rightChevronImageView: UIImageView!
    @IBOutlet var underlineView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        styleViews()
    }

    private func styleViews() {
        backgroundView = backdropView
        backgroundView?.backgroundColor = UIColor.backgroundOffWhite

        nameLabel.font = UIFont.connectionCountryFont
        nameLabel.textColor = UIColor.guardianBlack

        underlineView.backgroundColor = UIColor.guardianBorderGrey
    }

    static func height() -> CGFloat {
        return 56.0
    }
}
