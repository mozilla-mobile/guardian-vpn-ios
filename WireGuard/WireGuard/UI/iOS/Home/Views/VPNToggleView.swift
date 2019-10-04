// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

enum VPNState {
    case off
    case connecting
    case connected
    case switching
}

class VPNToggleView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var globeImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var vpnSwitch: UISwitch!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(String(describing: VPNToggleView.self), owner: self, options: nil)
        self.view.frame = self.bounds
        self.addSubview(self.view)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        vpnSwitch.isOn = false
        styleViews()
    }

    func styleViews() {
        titleLabel.text = "VPN is off"
        subtitleLabel.text = "Turn it on to protect your entire device"

        titleLabel.font = UIFont.vpnTitleFont
        titleLabel.textColor = UIColor.guardianBlack
        subtitleLabel.font = UIFont.vpnSubtitleFont
        subtitleLabel.textColor = UIColor.guardianGrey

        vpnSwitch.onTintColor = UIColor.toggleColor
    }

    public func applyDropShadow() {
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        backgroundColor = UIColor.clear

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2.0
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 4).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    // MARK: State Cha
}
