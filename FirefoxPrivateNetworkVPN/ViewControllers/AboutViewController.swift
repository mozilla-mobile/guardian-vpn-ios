//
//  AboutViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import RxSwift

class AboutViewController: UIViewController, Navigating {
    // MARK: Properties
    static var navigableItem: NavigableItem = .devices

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: AboutDataSource?
    private let disposeBag = DisposeBag()

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        dataSource = AboutDataSource(with: tableView)
        subscribeToRowSelected()
    }

    // MARK: Setup
    func setupNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil // enables back swipe

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = LocalizedString.aboutTitle.value
        navigationItem.titleView?.tintColor = UIColor.custom(.grey50)
        let chevron = UIImage(named: "icon_backChevron")?.withRenderingMode(.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: chevron, style: .plain, target: self, action: #selector(goBack))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.custom(.grey40)
    }

    @objc func goBack() {
        navigate(to: .settings)
    }

    private func subscribeToRowSelected() {
        //swiftlint:disable:next trailing_closure
        dataSource?.rowSelected
            .subscribe(onNext: { [weak self] url in
                self?.navigate(to: .safari, context: .url(url))
            })
            .disposed(by: disposeBag)
    }
}
