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
    private let account = { return DependencyFactory.sharedFactory.accountManager.account }()

    let trashTappedSubject = PublishSubject<Device>()
    let deletionConfirmedSubject = PublishSubject<Device>()
    let deletionCompletedSubject = PublishSubject<Result<Void, GuardianError>>()

    var deviceList: [Device] {
        var deviceList = account?.user?.devices.sorted { return $0.isCurrentDevice && !$1.isCurrentDevice } ?? []

        if let account = account, !account.hasDeviceBeenAdded {
            deviceList.insert(Device.mock(name: UIDevice.current.name), at: 0)
        }
        return deviceList
    }

    init() {
        subscribeToDeletionConfirmedObservable()
    }

    private func subscribeToDeletionConfirmedObservable() {
        deletionConfirmedSubject
            .flatMap { [weak self] device -> Single<Result<Void, GuardianError>> in
                return self?.account?.remove(device: device) ?? .never()

            }
        .subscribe(onNext: { [weak self] result in
            guard let self = self, let account = self.account else { return }

            if case .failure(let error) = result,
                case GuardianError.couldNotRemoveDevice(let device) = error {
                self.deletionCompletedSubject.onNext(.failure(GuardianError.couldNotRemoveDevice(device)))
                return
            }

            guard !account.hasDeviceBeenAdded else {
                self.deletionCompletedSubject.onNext(.success(()))
                return
            }
            account.addCurrentDevice { _ in
                self.deletionCompletedSubject.onNext(.success(()))
            }
        }).disposed(by: disposeBag)
    }

    private func formattedDeviceList(with devices: [Device]) -> [Device] {
        var deviceList = devices.sorted { return $0.isCurrentDevice && !$1.isCurrentDevice }

        if let account = account, !account.hasDeviceBeenAdded {
            deviceList.insert(Device.mock(name: UIDevice.current.name), at: 0)
        }
        return deviceList
    }
}
