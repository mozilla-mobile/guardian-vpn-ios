// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import RxSwift

class LoadingViewController: UIViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    let accountManager: AccountManaging
    weak var coordinatorDelegate: Navigating?

    var disposeBag = DisposeBag()
    let navigateSubject = PublishSubject<NavigationAction>()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(accountManager: AccountManaging, coordinatorDelegate: Navigating) {
        self.accountManager = accountManager
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: String(describing: LoadingViewController.self), bundle: Bundle.main)

        handleNavigationWithDelay(1)

        self.accountManager.setupFromAppLaunch { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigateSubject.onNext(.loginSucceeded)
                case .failure:
                    self?.navigateSubject.onNext(.loading)
                }
            }
        }
    }

    private func handleNavigationWithDelay(_ delay: Int) {
        Observable.combineLatest(
            Observable.just(()).delay(.seconds(delay), scheduler: MainScheduler.instance),
            navigateSubject.asObservable()
        ).subscribe { [weak self] event in
            guard let (_, navAction) = event.element else { return }
            self?.coordinatorDelegate?.navigate.onNext(navAction)
        }.disposed(by: disposeBag)
    }
}
