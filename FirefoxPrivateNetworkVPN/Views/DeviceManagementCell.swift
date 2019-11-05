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
    private let disposeBag = DisposeBag()

    func setup(with device: Device, indexPath: IndexPath, event: PublishSubject<IndexPath>) {
        nameLabel.text = device.name

        if device.isCurrentDevice {
            subtitleLabel.text = LocalizedString.devicesCurrentDevice.value
            subtitleLabel.textColor = UIColor.custom(.blue50)
            deleteButton.isHidden = true
            deleteButton.isEnabled = false
        } else {
            subtitleLabel.text = dateAddedString(from: device.createdAtDate)
            subtitleLabel.textColor = UIColor.custom(.grey40)
            deleteButton.isHidden = false
            deleteButton.isEnabled = true

            deleteButton.rx.tap.asControlEvent()
                .subscribe { _ in
                    event.onNext(indexPath)
            }.disposed(by: disposeBag)
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
