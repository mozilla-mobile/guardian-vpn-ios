//
//  LoadingViewController
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
import RxRelay

class LoadingViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .loading
    static let navigationDelay: DispatchTimeInterval = .seconds(1)

    @IBOutlet weak var nameLabel: UILabel!

    private let navigateRelay = PublishRelay<NavigableItem>()
    private let disposeBag = DisposeBag()

    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delayNavigation(timeInterval: Self.navigationDelay)

        guard let storedCredentials = Credentials.fetchFromUserDefaults() else {
            navigateRelay.accept(.landing)
            return
        }

        let account = Account(with: storedCredentials)
        account.finishSetup { [weak self] result in
            switch result {
            case .success:
                DependencyFactory.sharedFactory.set(account: account)
                self?.navigateRelay.accept(.home)
            case .failure:
                self?.navigateRelay.accept(.landing)
            }
        }
    }

    private func delayNavigation(timeInterval: DispatchTimeInterval) {
        Observable.combineLatest(
            Observable.just(()).delay(timeInterval, scheduler: MainScheduler.instance),
            navigateRelay.asObservable()
        ).subscribe { [weak self] event in
            guard let (_, destination) = event.element else { return }
            self?.navigate(to: destination)
        }.disposed(by: disposeBag)
    }
}
