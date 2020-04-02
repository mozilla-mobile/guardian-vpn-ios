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

    private var internalState = BehaviorRelay<VPNState>(value: .off)
    var stateEvent = BehaviorRelay<VPNState>(value: .off)
    var cityChangedEvent = PublishSubject<VPNCity>()
    var timeSinceConnected: Double {
        guard let connectionEstablishedTime = connectionEstablishedTime else { return 0 }

        return Double(Date().timeIntervalSince1970 - connectionEstablishedTime.timeIntervalSince1970)
    }

    private var connectionEstablishedTime: Date?
    private var lastSelectedCity: VPNCity?
    private var currentSelectedCity: VPNCity?
    private let disposeBag = DisposeBag()

    init() {
        TunnelManagerUtilities.observe(internalState,
                                       bindTo: stateEvent,
                                       disposedBy: disposeBag)

        //swiftlint:disable:next trailing_closure
        cityChangedEvent.subscribe(onNext: { [weak self] newSelectedCity in
            self?.lastSelectedCity = self?.currentSelectedCity
            self?.currentSelectedCity = newSelectedCity
        }).disposed(by: disposeBag)
    }

    func connect(with device: Device?) -> Single<Void> {
        internalState.accept(.connecting)
        internalState.accept(.on)
        connectionEstablishedTime = Date()
        return Single.just(())
    }

    func switchServer(with device: Device) -> Single<Void> {
        internalState.accept(.switching(lastSelectedCity?.name ?? "", currentSelectedCity?.name ?? ""))
        internalState.accept(.on)
        connectionEstablishedTime = Date()
        return Single.just(())
    }

    func stop() {
        internalState.accept(.disconnecting())
        internalState.accept(.off)
    }

    func stopAndRemove() {
        stop()
    }

    func getReceivedBytes(completionHandler: @escaping ((UInt?) -> Void)) {
        completionHandler(UInt(Date().timeIntervalSince1970)) // Fake receiving bytes
    }
}
