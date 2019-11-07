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

    func setup(with device: Device, indexPath: IndexPath, event: PublishSubject<String>) {
        nameLabel.text = device.name
        isSelected = device.isBeingRemoved
//        isUserInteractionEnabled = !device.isBeingRemoved
//        deleteButton.isUserInteractionEnabled = device.isCurrentDevice ? false : !device.isBeingRemoved
        deleteButton.isHidden = device.isCurrentDevice

        if device.isCurrentDevice {
            subtitleLabel.text = LocalizedString.devicesCurrentDevice.value
            subtitleLabel.textColor = UIColor.custom(.blue50)
        } else {
            subtitleLabel.text = dateAddedString(from: device.createdAtDate)
            subtitleLabel.textColor = UIColor.custom(.grey40)

            deleteButton.rx.tap.asControlEvent()
                .debounce(.seconds(2), scheduler: MainScheduler.instance)
                .subscribe { _ in
                    self.isUserInteractionEnabled = false
                    self.deleteButton.isUserInteractionEnabled = false
                    event.onNext(device.publicKey)
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
    }
}
