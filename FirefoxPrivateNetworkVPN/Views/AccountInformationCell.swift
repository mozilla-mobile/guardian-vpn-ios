//
//  AccountInformationCell
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class AccountInformationCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var accessoryIconImageView: UIImageView!
    @IBOutlet weak var disclosureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accessoryLabel: UILabel!

    static let height: CGFloat = UIScreen.isiPad ? 88.0 : 55.0

    func setup(_ type: SettingsItem, isSubscriptionActive: Bool, isDeviceAdded: Bool) {
        titleLabel.text = type.title
        titleLabel.textColor = type.textColor
        iconImageView.image = type.iconImage
        disclosureImageView.image = type.disclosureImage
        accessoryIconImageView.isHidden = true
        accessoryLabel.isHidden = true

        if type.navigableItem == .devices {
            if !isSubscriptionActive {
                accessoryLabel.text = LocalizedString.settingsPurchase.value
                accessoryLabel.isHidden = false
            } else if !isDeviceAdded {
                accessoryIconImageView.image = UIImage(named: "icon_alert")
                accessoryIconImageView.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
