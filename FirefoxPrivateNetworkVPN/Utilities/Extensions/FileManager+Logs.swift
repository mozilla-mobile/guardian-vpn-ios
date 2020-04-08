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
    static func getDebugLogs(completion: @escaping (Data?) -> Void) {
        guard let destinationDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completion(nil)
            return
        }

        let destinationURL = destinationDir.appendingPathComponent("log.txt")
        DispatchQueue.global(qos: .userInitiated).async {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                _ = FileManager.deleteFile(at: destinationURL)
            }

            _ = Logger.global?.writeLog(to: destinationURL.path)
            let data = try? Data(contentsOf: destinationURL)
            completion(data)
        }
    }
}
