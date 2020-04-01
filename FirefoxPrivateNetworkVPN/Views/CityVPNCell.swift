//
//  CityVPNCell
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import RxSwift

class CityVPNCell: UITableViewCell {

    static let estimatedHeight: CGFloat = UIScreen.isiPad ? 88 : 56

    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var radioImageView: UIImageView!
    @IBOutlet weak var connectionHealthIcon: UIImageView!

    private let disposeBag = DisposeBag()

    func setup(with cellModel: CityCellModel) {
        cityLabel.text = cellModel.name
        radioImageView.image = cellModel.isCellSelected ? UIImage(named: "icon_radioOn") : UIImage(named: "icon_radioOff")
        radioImageView.tintColor = cellModel.isCellSelected ? UIColor.custom(.blue50) : UIColor.custom(.grey40)
        radioImageView.alpha = cellModel.isCellDisabled ? 0.5 : 1

        if cellModel.isCellSelected {
            //swiftlint:disable:next trailing_closure
            cellModel.connectionHealthSubject
                .asDriver(onErrorJustReturn: .initial)
                .distinctUntilChanged()
                .drive(onNext: { [unowned self] connectionHealth in
                    self.connectionHealthIcon.image = connectionHealth.icon
                    self.connectionHealthIcon.isHidden = false
                }).disposed(by: disposeBag)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.connectionHealthIcon.isHidden = true
    }
}
