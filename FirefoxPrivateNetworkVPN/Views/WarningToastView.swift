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

    var errorMessage = NSAttributedString() {
        didSet {
            label.attributedText = errorMessage
        }
    }

    var callback: (() -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }

    func appear(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.label.alpha = 1
            }
        }
        self.label.alpha = 1
    }

    func scheduleDismissal(after timeInterval: TimeInterval = 3) {
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            UIView.animate(withDuration: 1) {
                self.label.alpha = 0
            }
        }
    }
}
