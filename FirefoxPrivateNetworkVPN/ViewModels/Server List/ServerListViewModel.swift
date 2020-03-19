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

typealias SectionExpansionState = (section: Int, rows: [IndexPath], isExpanded: Bool)

class ServerListViewModel {

    // MARK: - Properties
    private static let sectionHeaderCount = 1
    private var serverList: [VPNCountry] {
        return DependencyFactory.sharedFactory.accountManager.availableServers ?? []
    }
    private let disposeBag = DisposeBag()
    private let _vpnSelection = PublishSubject<Void>()
    private let _toggleSection = PublishSubject<SectionExpansionState>()

    private lazy var sectionExpandedStates: [Int: Bool] = {
        var states = [Int: Bool]()
        if let selectedCityIndexPath = selectedCityIndexPath {
            states[selectedCityIndexPath.section] = true
        }
        return states
    }()

    let cellSelection = PublishSubject<IndexPath>()
    var selectedCityIndexPath: IndexPath?

    var vpnSelection: Observable<Void> {
        return _vpnSelection.asObservable()
    }

    var toggleSection: Observable<SectionExpansionState> {
        return _toggleSection.asObservable()
    }

    var numberOfSections: Int {
        return serverList.count
    }

    init() {
        self.selectedCityIndexPath = getIndexPathOfCurrentCity()
        setupObservers()
    }

    func getRowCount(for section: Int) -> Int {
        if let isExpanded = sectionExpandedStates[section], isExpanded == true {
            return serverList[section].cities.count + ServerListViewModel.sectionHeaderCount
        }
        return ServerListViewModel.sectionHeaderCount
    }

    func getCountryCellModel(at section: Int) -> CountryCellModel {
        return CountryCellModel(name: serverList[section].name,
                                countryCode: serverList[section].code,
                                isExpanded: sectionExpandedStates[section] ?? false)
    }

    func getCityCellModel(at indexPath: IndexPath) -> CityCellModel {
        let city = serverList[indexPath.section].cities[indexPath.row - ServerListViewModel.sectionHeaderCount]
        return CityCellModel(name: city.name,
                             isSelected: indexPath == selectedCityIndexPath)
    }

    //Find the saved city in the server list each time in case the list has changed
    private func getIndexPathOfCurrentCity() -> IndexPath? {
        let currentCity = VPNCity.fetchFromUserDefaults() ?? serverList.getRandomUSCity()
        for (countryIndex, country) in serverList.enumerated() {
            for (cityIndex, city) in country.cities.enumerated() where city == currentCity {
                return IndexPath(row: cityIndex + ServerListViewModel.sectionHeaderCount, section: countryIndex)
            }
        }
        return nil
    }

    private func getCityRows(for section: Int) -> [IndexPath] {
        return (1...self.serverList[section].cities.count).map {
            return IndexPath(row: $0, section: section)
        }
    }

    //swiftlint:disable trailing_closure
    private func setupObservers() {
        cellSelection
            .filter { $0.isCityCell }
            .do(onNext: { [weak self] indexPath in
                guard let self = self, indexPath != self.selectedCityIndexPath else { return }
                self.selectedCityIndexPath = indexPath
                let newCity = self.serverList[indexPath.section].cities[indexPath.row - ServerListViewModel.sectionHeaderCount]
                newCity.saveToUserDefaults()
                DependencyFactory.sharedFactory.tunnelManager.cityChangedEvent.onNext(newCity)
            })
            .flatMap { _ -> Single<Void> in
                guard let device = DependencyFactory.sharedFactory.accountManager.account?.currentDevice else {
                    OSLog.log(.error, "No device found when switching VPN server")
                    return .never()
                }
                return DependencyFactory.sharedFactory.tunnelManager.switchServer(with: device)
        }
        .catchError { error -> Observable<Void> in
            OSLog.logTunnel(.error, error.localizedDescription)
            NotificationCenter.default.post(Notification(name: .switchServerError))
            return Observable.just(())
        }
        .subscribe(onNext: { [weak self] in
            self?._vpnSelection.onNext(())
        }).disposed(by: disposeBag)

        cellSelection
            .filter { $0.isCountryHeader }
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let currentExpansionState = self.sectionExpandedStates[indexPath.section] ?? false
                let updatedExpansionState = !currentExpansionState
                self.sectionExpandedStates[indexPath.section] = updatedExpansionState
                self._toggleSection.onNext((indexPath.section, self.getCityRows(for: indexPath.section), updatedExpansionState))
            }).disposed(by: disposeBag)
    }
}

private extension IndexPath {
    var isCountryHeader: Bool {
        return row == 0
    }

    var isCityCell: Bool {
        return row != 0
    }
}
