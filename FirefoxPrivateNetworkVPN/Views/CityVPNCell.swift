//
//  CityVPNCell
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class CityVPNCell: UITableViewCell {

    static let estimatedHeight: CGFloat = UIScreen.isiPad ? 88 : 56

    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var radioImageView: UIImageView!

    func setup(with cellModel: CityCellModel) {
        cityLabel.text = cellModel.name
        radioImageView.image = cellModel.isSelected ? UIImage(named: "icon_radioOn") : UIImage(named: "icon_radioOff")
        radioImageView.tintColor = cellModel.isSelected ? UIColor.custom(.blue50) : UIColor.custom(.grey40)
    }
}
