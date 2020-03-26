//
//  DeviceManagementViewModel
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import RxSwift
import RxCocoa
import UIKit

class DeviceManagementViewModel {
    private let disposeBag = DisposeBag()
    private let accountManager = DependencyManager.shared.accountManager
    private var account: Account? { accountManager.account }

    let trashTappedSubject = PublishSubject<Device>()
    let deletionConfirmedSubject = PublishSubject<Device>()
    let deletionSuccessSubject = PublishSubject<Void>()
    let deletionErrorSubject = PublishSubject<GuardianAppError>()

    var sortedDevices: [Device] {
        //sort so the current device is always first in the list
        var devices = account?.user.devices.sorted {
            return $0 == account?.currentDevice && !($1 == account?.currentDevice)
            } ?? []

        //if their device could not be added because they're over their device limit, add a mock device to display as their current one
        if let account = account, !account.hasDeviceBeenAdded {
            devices.insert(Device.mock(name: UIDevice.current.name), at: 0)
        }
        return devices
    }

    init() {
        subscribeToDeletionConfirmedObservable()
    }

    private func subscribeToDeletionConfirmedObservable() {
        //swiftlint:disable:next trailing_closure
        deletionConfirmedSubject
            .flatMap { [unowned self] device -> Observable<Event<Void>> in
                return self.accountManager.remove(device: device).asObservable().materialize()
        }.subscribe(onNext: { [unowned self] event in
            guard let account = self.accountManager.account else { return }

            switch event {
            case .next:
                if account.hasDeviceBeenAdded {
                    self.deletionSuccessSubject.onNext(())
                } else {
                    Logger.global?.log(message: "Adding current device after removal")
                    self.accountManager.addCurrentDevice { _ in
                        self.deletionSuccessSubject.onNext(())
                    }
                }
            case .error(let error):
                guard case GuardianAppError.couldNotRemoveDevice(let device) = error else { return }
                self.deletionErrorSubject.onNext(GuardianAppError.couldNotRemoveDevice(device))
            default: break
            }
        }).disposed(by: disposeBag)
    }
}
