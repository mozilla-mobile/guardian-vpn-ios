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

class ServerListViewModel: NSObject {
    private var serverList: [ServerListItem]
    let vpnSelection = PublishSubject<Void>()

    var numberOfSections: Int {
        return serverList.count
    }

    override init() {
        serverList = DependencyFactory.sharedFactory.accountManager.availableServers?.map {
            return ServerListItem(country: $0, isExpanded: false)
        } ?? []
        super.init()
    }

    func getRowCount(for section: Int) -> Int {
        return serverList[section].isExpanded ? serverList[section].country.cities.count : 1
    }

    func getCountry(at section: Int) -> ServerListItem {
        return serverList[section]
    }

    func getCity(at indexPath: IndexPath) -> VPNCity {
        return serverList[indexPath.section].country.cities[indexPath.row - 1]
    }

    func toggle(section: Int) {
        serverList[section].isExpanded.toggle()
        // Rx call to reload sections
//        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }

    func selectCity(at indexPath: IndexPath) {
        let newSelection = serverList[indexPath.section].country.cities[indexPath.row - 1]
        newSelection.saveToUserDefaults()
        let tunnelManager = DependencyFactory.sharedFactory.tunnelManager
        tunnelManager.cityChangedEvent.onNext(newSelection)

//        if indexPath != selectedIndexPath {
//            selectedIndexPath = indexPath
//            tableView.reloadData()

            vpnSelection.onNext(())
//        }
    }
}

struct ServerListItem {
    let country: VPNCountry
    var isExpanded: Bool = false
}
