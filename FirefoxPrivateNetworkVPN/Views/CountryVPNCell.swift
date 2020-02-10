//
//  ServerSectionHeaderViewCell
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit
import RxSwift

class CountryVPNCell: UITableViewCell {

    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var chevronImageView: UIImageView!

    func setup(with cellModel: CountryCellModel) {
        flagImageView.image = UIImage(named: "flag_\(cellModel.countryCode.lowercased())")
        nameLabel.text = cellModel.name
        topLineView.isHidden = cellModel.isExpanded
        chevronImageView.image = cellModel.isExpanded ? #imageLiteral(resourceName: "icon_sectionOpen") : #imageLiteral(resourceName: "icon_sectionClosed")
    }
}
