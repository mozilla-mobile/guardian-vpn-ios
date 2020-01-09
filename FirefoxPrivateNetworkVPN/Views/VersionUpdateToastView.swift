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

@IBDesignable
final class VersionUpdateToastView: UIView {

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private var view: UIView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)

        label.attributedText = NSAttributedString.formatted(LocalizedString.toastFeaturesAvailable.value,
                                                            actionMessage: LocalizedString.toastUpdateNow.value)
    }

    @IBAction private func dismiss(_ sender: Any) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.removeFromSuperview()
        }
    }

    @IBAction private func tapped(_ sender: UITapGestureRecognizer) {
        //open App Store
        DependencyFactory.sharedFactory.navigationCoordinator
            .navigate(from: .home, to: .appStore)
    }
}
