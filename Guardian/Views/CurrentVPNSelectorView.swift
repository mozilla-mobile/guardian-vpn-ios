//
//  CurrentVPNSelectorView
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit
import RxSwift

// TODO: Redo THIS XIB ENTIRELY

class CurrentVPNSelectorView: UIView {
    @IBOutlet var countryFlagImageView: UIImageView!
    @IBOutlet var countryTitleLabel: UILabel!

    private let disposeBag = DisposeBag()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        DependencyFactory.sharedFactory.tunnelManager.cityChangedEvent
            .map { Optional($0) }
            .startWith(VPNCity.fetchFromUserDefaults())
            .compactMap { $0 }
            .subscribe { cityEvent in
                guard let city = cityEvent.element?.name else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.countryTitleLabel.text = city
                    if let countryCode = DependencyFactory.sharedFactory.accountManager.countryCodeForCity(city) {
                        self?.countryFlagImageView.image = UIImage(named: countryCode)
                    } else {
                        self?.countryFlagImageView.image = nil
                    }
                }
        }.disposed(by: disposeBag)
    }
}
