//
//  CityVPNCell
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

class CityVPNCell: UITableViewCell {

    static let height: CGFloat = 55.0

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
