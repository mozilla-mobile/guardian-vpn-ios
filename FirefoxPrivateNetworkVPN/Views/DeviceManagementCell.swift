//
//  DeviceManagementCell
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DeviceManagementCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    private var disposeBag = DisposeBag()
    private var deviceKey: String?
    private var removeDeviceEvent: PublishSubject<String>?

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        deviceKey = nil
        removeDeviceEvent = nil
        nameLabel.text = nil
    }

    func setup(with device: Device, event: PublishSubject<String>) {
        nameLabel.text = device.name
        deviceKey = device.publicKey
        removeDeviceEvent = event

        if device.isCurrentDevice {
            subtitleLabel.text = LocalizedString.devicesCurrentDevice.value
            applyCurrentDeviceStyle()
        } else if device.isBeingRemoved {
            subtitleLabel.text = dateAddedString(from: device.createdAtDate)
            applyDisabledStyle()
        } else {
            subtitleLabel.text = dateAddedString(from: device.createdAtDate)
            applyEnabledStyle()
        }
    }

    func applyCurrentDeviceStyle() {
        isUserInteractionEnabled = true
        iconImageView.tintColor = UIColor.custom(.grey50)
        nameLabel.textColor = UIColor.custom(.grey50)
        subtitleLabel.textColor = UIColor.custom(.blue50)
        deleteButton.tintColor = UIColor.custom(.red50)
        deleteButton.isHidden = true
    }

    func applyDisabledStyle() {
        isUserInteractionEnabled = false
        iconImageView.tintColor = UIColor.custom(.grey20)
        nameLabel.textColor = UIColor.custom(.grey20)
        subtitleLabel.textColor = UIColor.custom(.grey20)
        deleteButton.isHidden = true
        deleteButton.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()
    }

    func applyEnabledStyle() {
        isUserInteractionEnabled = true
        iconImageView.tintColor = UIColor.custom(.grey50)
        nameLabel.textColor = UIColor.custom(.grey50)
        subtitleLabel.textColor = UIColor.custom(.grey40)
        deleteButton.tintColor = UIColor.custom(.red50)
        deleteButton.isHidden = false
        activityIndicatorView.stopAnimating()
    }

    private func dateAddedString(from date: Date) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1

        guard let dateString = formatter.string(from: date, to: Date()) else {
            return nil
        }
        return String(format: LocalizedString.devicesAddedDate.value, dateString)
    }

    @IBAction func removeDevice() {
        if let removeDeviceEvent = removeDeviceEvent, let deviceKey = deviceKey {
            applyDisabledStyle()
            removeDeviceEvent.onNext(deviceKey)
        }
    }
}
