// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import RxSwift

class CountryVPNHeaderView: UITableViewHeaderFooterView {
    static let height: CGFloat = 56.0

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var backdropView: UIView!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var topLineView: UIView!

    weak var tapPublishSubject: PublishSubject<CountryVPNHeaderView>?

    var isExpanded: Bool = false {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.chevronImageView.image = newValue ? #imageLiteral(resourceName: "down_chevron") : #imageLiteral(resourceName: "right_chevron")
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        styleViews()
        setupTaps()
    }

    func setup(country: VPNCountry) {
        flagImageView.image = UIImage(named: country.code.uppercased())
        nameLabel.text = country.name
        topLineView.isHidden = tag == 0
    }

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        tapPublishSubject?.onNext(self)
    }

    private func styleViews() {
        backgroundView = backdropView
        backgroundView?.backgroundColor = UIColor.backgroundOffWhite

        nameLabel.font = UIFont.connectionCountryFont
        nameLabel.textColor = UIColor.guardianBlack
        topLineView.backgroundColor = UIColor.guardianBorderGrey
    }

    private func setupTaps() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        addGestureRecognizer(tapRecognizer)
    }
}
