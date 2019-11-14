//
//  Account
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import UIKit

class Account {
    private var credentials: Credentials
    private(set) var currentDevice: Device?
    private(set) var user: User?

    var token: String {
        return credentials.verificationToken
    }

    var publicKey: Data {
        return credentials.deviceKeys.publicKey
    }

    var privateKey: Data {
        return credentials.deviceKeys.privateKey
    }

    var hasDeviceBeenAdded: Bool {
        return currentDevice != nil
    }

    init(credentials: Credentials, user: User? = nil, currentDevice: Device? = nil) {
        self.credentials = credentials
        self.user = user
        self.currentDevice = currentDevice
    }

    func addCurrentDevice(completion: @escaping (Result<Device, Error>) -> Void) {
        guard let devicePublicKey = credentials.deviceKeys.publicKey.base64Key() else {
            completion(Result.failure(GuardianError.couldNotEncodeData))
            return
        }
        let body: [String: Any] = ["name": UIDevice.current.name,
                                   "pubkey": devicePublicKey]

        GuardianAPI.addDevice(with: credentials.verificationToken, body: body) { [unowned self] result in
            switch result {
            case .success(let device):
                self.currentDevice = device
                device.saveToUserDefaults()
                self.setUser { _ in } //TODO: Change this to make get devices call when its available
                completion(.success(device))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func setUser(completion: @escaping (Result<Void, Error>) -> Void) {
          GuardianAPI.accountInfo(token: credentials.verificationToken) { [unowned self] result in
//              if case .failure = result {
//                  self.heartbeatFailedEvent.onNext(())
//              }
              completion(result.map { user in
                  self.user = user
                  return ()
              })
          }
      }

    func removeDevice(with deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        user?.deviceIsBeingRemoved(with: deviceKey)
        GuardianAPI.removeDevice(with: credentials.verificationToken, deviceKey: deviceKey) { [unowned self] result in
            switch result {
            case .success:
                self.user?.removeDevice(with: deviceKey)
                completion(.success(()))
            case .failure(let error):
                self.user?.deviceFailedRemoval(with: deviceKey)
                completion(.failure(error))
            }
        }
    }
}
