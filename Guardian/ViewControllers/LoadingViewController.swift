//
//  LoadingViewController
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
        setStrings()
        
        delayNavigation(timeInterval: Self.navigationDelay)
        
        let accountManager = DependencyFactory.sharedFactory.accountManager
        accountManager.setupFromAppLaunch(completion: { [weak self] result in
            switch result {
            case .success:
                self?.navigateRelay.accept(.home)
            case .failure:
                self?.navigateRelay.accept(.landing)
            }
        })
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
    
    private func setStrings() {
        nameLabel.accessibilityLabel = "LoadingViewController_Name"
        nameLabel.text = NSLocalizedString(nameLabel.accessibilityLabel!, comment: "")
    }
}
