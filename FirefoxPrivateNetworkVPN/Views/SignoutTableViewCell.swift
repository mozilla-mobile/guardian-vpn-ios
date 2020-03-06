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
    @IBOutlet weak var signoutButton: UIButton!
    let signoutSubject = PublishSubject<Void>()

    override func awakeFromNib() {
        super.awakeFromNib()

        signoutButton.setTitle(LocalizedString.settingsSignOut.value, for: .normal)
    }

    @IBAction func signoutSelected() {
        signoutSubject.onNext(())
    }
}
