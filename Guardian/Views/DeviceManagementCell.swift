// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class DeviceManagementCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    func setup(with device: Device) {
        nameLabel.text = device.name

        if device.isCurrentDevice {
            subtitleLabel.text = "Current device"
            subtitleLabel.textColor = #colorLiteral(red: 0, green: 0.3839950562, blue: 0.9068421125, alpha: 1)
            deleteButton.isHidden = true
        } else {
            subtitleLabel.text = dateAddedString(from: device.createdAtDate)
            subtitleLabel.textColor = #colorLiteral(red: 0.04704938084, green: 0.0470656082, blue: 0.05134283006, alpha: 0.6)
            deleteButton.isHidden = false
        }
    }

    private func dateAddedString(from date: Date) -> String? {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1

        if let dateString = formatter.string(from: date, to: Date()) {
            return "About \(dateString) ago"
        } else {
            return nil
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
