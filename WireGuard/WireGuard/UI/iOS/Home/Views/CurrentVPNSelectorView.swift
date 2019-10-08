// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class CurrentVPNSelectorView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var countryFlagImageView: UIImageView!
    @IBOutlet var countryTitleLabel: UILabel!

    var selectedCountry: VPNCountry?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(String(describing: CurrentVPNSelectorView.self), owner: self, options: nil)
        self.view.frame = self.bounds
        self.addSubview(self.view)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        styleViews()
    }

    func styleViews() {
        countryTitleLabel.text = selectedCountry?.name ?? "Australia"

        countryTitleLabel.font = UIFont.vpnSelectorTitleFont
        countryTitleLabel.textColor = UIColor.guardianGrey

        layer.masksToBounds = true
        layer.borderColor = UIColor.guardianBorderGrey.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 22
    }
}
