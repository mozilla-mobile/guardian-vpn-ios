//
//  TopBannerView
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

final class TopBannerView: UIView {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private var view: UIView!
    @IBOutlet private weak var dismissView: UIView!

    private var action: (() -> Void)?
    private var dismiss: (() -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        layoutIfNeeded()
        setCornerRadius()
    }

    private func setCornerRadius() {
        view.cornerRadius = view.frame.height/10
        view.shadowRadius = view.frame.height/10
        dismissView.cornerRadius = dismissView.frame.height/10
        dismissView.shadowRadius = dismissView.frame.height/10
    }

    func configure(text: NSAttributedString, action: @escaping () -> Void, dismiss: (() -> Void)? = nil) {
        label.attributedText = text
        dismissView.isHidden = dismiss == nil
        self.action = action
        self.dismiss = dismiss
    }

    @IBAction private func dismiss(_ sender: Any) {
        dismiss?()
    }

    @IBAction private func tapped(_ sender: UITapGestureRecognizer) {
        action?()
    }
}
