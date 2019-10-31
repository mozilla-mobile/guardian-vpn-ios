// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit
import RxSwift

class CountryVPNHeaderView: UITableViewHeaderFooterView {
    static let height: CGFloat = 56.0

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var backdropView: UIView!
    @IBOutlet var chevronImageView: UIImageView!
    @IBOutlet var underlineView: UIView!

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

    @objc private func handleTap(sender: UITapGestureRecognizer) {
        tapPublishSubject?.onNext(self)
    }

    private func styleViews() {
        backgroundView = backdropView
        backgroundView?.backgroundColor = UIColor.backgroundOffWhite

        nameLabel.font = UIFont.connectionCountryFont
        nameLabel.textColor = UIColor.guardianBlack

        underlineView.backgroundColor = UIColor.guardianBorderGrey
    }

    private func setupTaps() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        addGestureRecognizer(tapRecognizer)
    }
}
