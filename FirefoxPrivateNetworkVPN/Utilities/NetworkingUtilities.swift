//
//  NetworkingUtilities
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

class NetworkingUtilities {

    static var userAgentInfo: String {
        return UIApplication.appNameWithoutSpaces + "/" + UIApplication.appVersion
            + " " + UIDevice.modelName + "/" + UIDevice.current.systemVersion
    }
}
