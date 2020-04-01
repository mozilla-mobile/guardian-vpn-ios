//
//  CityCellModel
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import RxSwift

struct CityCellModel {
    let name: String
    let isSelected: Bool
    let isDisabled: Bool
    let connectionHealthSubject: Observable<ConnectionHealth>
}
