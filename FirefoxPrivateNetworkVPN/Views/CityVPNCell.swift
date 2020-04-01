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

    //swiftlint:disable:next implicitly_unwrapped_optional
    private var model: CityCellModel!
    private let disposeBag = DisposeBag()

    func setup(with cellModel: CityCellModel) {
        model = cellModel

        cityLabel.text = model.name
        radioImageView.image = model.isCellSelected ? UIImage(named: "icon_radioOn") : UIImage(named: "icon_radioOff")
        radioImageView.tintColor = model.isCellSelected ? UIColor.custom(.blue50) : UIColor.custom(.grey40)
        radioImageView.alpha = model.isCellDisabled ? 0.5 : 1

        //swiftlint:disable:next trailing_closure
        model.connectionHealthSubject
            .asDriver(onErrorJustReturn: .initial)
            .drive(onNext: { [unowned self] connectionHealth in
                guard self.model.isCellSelected else {
                    self.connectionHealthIcon.isHidden = true
                    return
                }

                self.connectionHealthIcon.image = connectionHealth.icon
                self.connectionHealthIcon.isHidden = false
            }).disposed(by: disposeBag)
    }
}
