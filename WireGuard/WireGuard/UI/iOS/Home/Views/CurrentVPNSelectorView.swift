// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import RxSwift

class CurrentVPNSelectorView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var countryFlagImageView: UIImageView!
    @IBOutlet var countryTitleLabel: UILabel!

    var selectedCountry: VPNCountry?
    private let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(String(describing: CurrentVPNSelectorView.self), owner: self, options: nil)
        self.view.frame = self.bounds
        self.addSubview(self.view)

        // VPNCity... get observable of when we change cities...
        // first event from VPNCity from user defaults

        DependencyFactory.sharedFactory.tunnelManager.cityChangedEvent
            .map { Optional($0) }
            .startWith(VPNCity.fetchFromUserDefaults())
            .compactMap { $0 }
            .subscribe { cityEvent in
                guard let city = cityEvent.element?.name else { return }
                DispatchQueue.main.async { [weak self] in
                    self?.countryTitleLabel.text = city
                    self?.countryFlagImageView.image = nil // TODO: Need the country as well in order to set the flag
                }
        }.disposed(by: disposeBag)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        styleViews()
    }

    func styleViews() {
        countryTitleLabel.text = selectedCountry?.name ?? "Australia"

        countryTitleLabel.font = UIFont.vpnSelectorTitleFont
        countryTitleLabel.textColor = UIColor.guardianGrey

        layer.masksToBounds = true
        layer.borderColor = UIColor.guardianBorderGrey.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 22
    }
}