//
//  ServerListViewModel
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import RxSwift
import os.log

class ServerListViewModel: NSObject {
    private var serverList: [VPNCountry]
    private let disposeBag = DisposeBag()
    private let sectionHeaderCount = 1

    let cellSelection = PublishSubject<IndexPath>()
    let vpnSelection = PublishSubject<Void>()
    let toggleSection = PublishSubject<IndexPath>()

    var numberOfSections: Int {
        return serverList.count
    }

    //find the saved city in the server list in case the list has changed
    lazy var selectedCityIndexPath: IndexPath = {
        let currentCity = VPNCity.fetchFromUserDefaults() ?? serverList.getRandomUSServer()
        for (countryIndex, country) in serverList.enumerated() {
            for (cityIndex, city) in country.cities.enumerated() where city == currentCity {
                return IndexPath(row: cityIndex, section: countryIndex)
            }
        }
        return IndexPath(row: 0, section: 0)
    }()

    private lazy var sectionExpandedStates: [Int: Bool] = {
        var states = [Int: Bool]()
        states[selectedCityIndexPath.section] = true
        return states
    }()

    override init() {
        self.serverList = [VPNCountry].fetchFromUserDefaults() ?? []

        super.init()

        setupObservers()
    }

    func getRowCount(for section: Int) -> Int {
        if let isExpanded = sectionExpandedStates[section], isExpanded == true {
            return serverList[section].cities.count + sectionHeaderCount
        }
        return sectionHeaderCount
    }

    func getCountryCellModel(at section: Int) -> CountryCellModel {
        return CountryCellModel(name: serverList[section].name,
                                countryCode: serverList[section].code,
                                isExpanded: sectionExpandedStates[section] ?? false)
    }

    func getCityCellModel(at indexPath: IndexPath) -> CityCellModel {
        let row = indexPath.row - sectionHeaderCount
        let city = serverList[indexPath.section].cities[row]
        return CityCellModel(name: city.name,
                             isSelected: IndexPath(row: row, section: indexPath.section) == selectedCityIndexPath)
    }

    //swiftlint:disable trailing_closure
    private func setupObservers() {
        cellSelection
            .filter { $0.row != 0 }
            .do(onNext: { [weak self] indexPath in
                guard let self = self, indexPath != self.selectedCityIndexPath else {
                    return
                }
                self.selectedCityIndexPath = indexPath
                let newCity = self.serverList[indexPath.section].cities[indexPath.row - 1]
                newCity.saveToUserDefaults()
                DependencyFactory.sharedFactory.tunnelManager.cityChangedEvent.onNext(newCity)
                self.vpnSelection.onNext(())
            })
            .flatMap { _ -> Single<Void> in
                guard let device = DependencyFactory.sharedFactory.accountManager.account?.currentDevice else {
                    OSLog.log(.error, "No device found when switching VPN server")
                    return .never()
                }
                return DependencyFactory.sharedFactory.tunnelManager.switchServer(with: device)
        }
        .subscribe(onError: { error in
            OSLog.logTunnel(.error, error.localizedDescription)
            NotificationCenter.default.post(Notification(name: .switchServerError))
        }).disposed(by: disposeBag)

        cellSelection
            .filter { $0.row == 0 }
            .subscribe(onNext: { [weak self] indexPath in
                self?.sectionExpandedStates[indexPath.section] = self?.sectionExpandedStates[indexPath.section] ?? false
                self?.sectionExpandedStates[indexPath.section]?.toggle()
                self?.toggleSection.onNext(indexPath)
            }).disposed(by: disposeBag)
    }
}
