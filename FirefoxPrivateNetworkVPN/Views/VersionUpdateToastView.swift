//
//  UpdateToastView
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

final class VersionUpdateToastView: UIView {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private var view: UIView!
    @IBOutlet private weak var dismissView: UIView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)

        label.attributedText = NSAttributedString.formatted(LocalizedString.toastFeaturesAvailable.value,
                                                            actionMessage: LocalizedString.updateNow.value)
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

    @IBAction private func dismiss(_ sender: Any) {
        dismissView.backgroundColor = .custom(.blue80)

        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
                        self?.alpha = 0
            },
                       completion: { [weak self] _ in
                        self?.isHidden = true
        })
    }

    @IBAction private func tapped(_ sender: UITapGestureRecognizer) {
        DependencyManager.shared.navigationCoordinator
            .navigate(from: .home, to: .appStore)
    }
}
