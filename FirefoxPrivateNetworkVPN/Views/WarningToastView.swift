//
//  ErrorToastView
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

@IBDesignable
final class WarningToastView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet private weak var label: UILabel!

    typealias Action = (() -> Void)

    private var action: Action?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }

    func show(message: NSMutableAttributedString, dismissAfter: TimeInterval = 3, action: Action? = nil) {
        label.attributedText = message
        self.action = action
        UIView.animate(withDuration: 0.5) {
            self.alpha = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
            self.dismiss()
        }
    }

    @IBAction func tapped(_ sender: Any) {
        action?()
        dismiss()
    }

    private func dismiss() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }
    }
}
