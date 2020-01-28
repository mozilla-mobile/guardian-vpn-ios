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

    static let height: CGFloat = UIScreen.isiPad ? 87.0 : 55.0

    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var radioImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(city: VPNCity) {
        cityLabel.text = city.name
        radioImageView.image = city.isCurrentCity ? UIImage(named: "icon_radioOn") : UIImage(named: "icon_radioOff")
        radioImageView.tintColor = city.isCurrentCity ? UIColor.custom(.blue50) : UIColor.custom(.grey40)
    }
}
