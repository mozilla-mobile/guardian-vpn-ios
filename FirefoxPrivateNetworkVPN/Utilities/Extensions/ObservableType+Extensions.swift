//
//  ObservableType+Extensions
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import RxSwift

// Reference: https://stackoverflow.com/a/36050818
extension ObservableType {

    func withPrevious(count: Int = 2) -> Observable<[Element]> {
        return scan([]) { lastSlice, newValue in
            Array(lastSlice + [newValue]).suffix(count)
        }.filter { $0.count == count }
    }
}
