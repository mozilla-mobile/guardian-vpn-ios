//
//  SignoutTableViewCell
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

class SignoutTableViewCell: UITableViewCell {
    static let height: CGFloat = UIScreen.isiPad ? 104.0 : 71.0

    @IBOutlet weak var signoutButton: UIButton!
    weak var signoutSubject: PublishSubject<Void>?

    override func awakeFromNib() {
        super.awakeFromNib()

        signoutButton.setTitle(LocalizedString.settingsSignOut.value, for: .normal)
    }

    @IBAction func signoutSelected() {
        signoutSubject?.onNext(())
    }
}
