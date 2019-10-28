// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation
import RxSwift

enum NavigationAction {
    case loginSucceeded
    case loginFailed
    case vpnNewSelection
    case logout
    case loading
}

protocol Navigating: class {
    var navigate: PublishSubject<NavigationAction> { get }
}
