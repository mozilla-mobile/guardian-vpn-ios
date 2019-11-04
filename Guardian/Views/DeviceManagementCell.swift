//
//  DeviceManagementCell
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

class DeviceManagementCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    func setup(with device: Device) {
        nameLabel.text = device.name

        if device.isCurrentDevice {
            subtitleLabel.text = LocalizedString.devicesCurrentDevice.value
            subtitleLabel.textColor = UIColor.custom(.blue50)
            deleteButton.isHidden = true
        } else {
            subtitleLabel.text = dateAddedString(from: device.createdAtDate)
            subtitleLabel.textColor = UIColor.custom(.grey40)
            deleteButton.isHidden = false
        }
    }

    private func dateAddedString(from date: Date) -> String? {
        let formatter = DateComponentsFormatter()

        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1

        if let dateString = formatter.string(from: date, to: Date()) {
            return String(format: LocalizedString.devicesAddedDate.value, dateString)
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
