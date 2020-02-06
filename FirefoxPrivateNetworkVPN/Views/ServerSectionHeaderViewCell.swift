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

class ServerSectionHeaderViewCell: UITableViewCell {

    weak var tapPublishSubject: PublishSubject<ServerSectionHeaderViewCell>?
    var isExpanded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupTaps()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

        func setup(country: VPNCountry) {
    //        flagImageView.image = UIImage(named: "flag_\(country.code.lowercased())")
    //        nameLabel.text = country.name
    //        topLineView.isHidden = tag == 0
        }

        @objc private func handleTap(sender: UITapGestureRecognizer) {
            tapPublishSubject?.onNext(self)
        }

        private func setupTaps() {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            addGestureRecognizer(tapRecognizer)
        }

}
