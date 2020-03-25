//
//  SimulatorTunnelManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation
import RxSwift
import RxCocoa

class SimulatorTunnelManager: TunnelManaging {

    var cityChangedEvent = PublishSubject<VPNCity>()
    var stateEvent = BehaviorRelay<VPNState>(value: .off)
    var timeSinceConnected: Double {
        guard let connectionEstablishedTime = connectionEstablishedTime else { return 0 }

        return Double(Date().timeIntervalSince1970 - connectionEstablishedTime.timeIntervalSince1970)
    }

    private var connectionEstablishedTime: Date?
    private var lastSelectedCity: VPNCity?
    private var currentSelectedCity: VPNCity?
    private let disposeBag = DisposeBag()

    init() {
        //swiftlint:disable:next trailing_closure
        cityChangedEvent.subscribe(onNext: { [weak self] newSelectedCity in
            self?.lastSelectedCity = self?.currentSelectedCity
            self?.currentSelectedCity = newSelectedCity
        }).disposed(by: disposeBag)
    }

    func connect(with device: Device?) -> Single<Void> {
        stateEvent.accept(.connecting)
        stateEvent.accept(.on)
        connectionEstablishedTime = Date()
        return Single.just(())
    }

    func switchServer(with device: Device) -> Single<Void> {
        stateEvent.accept(.switching(lastSelectedCity?.name ?? "", currentSelectedCity?.name ?? ""))
        stateEvent.accept(.on)
        connectionEstablishedTime = Date()
        return Single.just(())
    }

    func stop() {
        stateEvent.accept(.disconnecting)
        stateEvent.accept(.off)
    }

    func stopAndRemove() {
        stop()
    }

    func getReceivedBytes(completionHandler: @escaping ((UInt?) -> Void)) {
        completionHandler(UInt(Date().timeIntervalSince1970)) // Fake receiving bytes
    }
}
