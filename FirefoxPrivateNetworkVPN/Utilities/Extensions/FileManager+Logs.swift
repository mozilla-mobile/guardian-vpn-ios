//
//  LogsFileManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

extension FileManager {
    static var debugLogs: Data? {
        do {
            guard let fileURL = FileManager.logFileURL,
                try fileURL.checkResourceIsReachable()
                else { return nil }
            //decode and then encode back to data??
            return try NSData(contentsOf: fileURL) as Data
        } catch {
            return nil
        }
    }
}
