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

enum WarningToastViewType {
    case positive, negative

    var backgroundColor: UIColor {
        switch self {
        case .positive: return UIColor.custom(.green50)
        case .negative: return UIColor.custom(.red50)
        }
    }

    var textColor: UIColor {
        switch self {
        case .positive: return .black
        case .negative: return .white
        }
    }
}

final class WarningToastView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet private weak var label: UILabel!

    typealias Action = (() -> Void)

    private var action: Action?
    private var dismissTimer: Timer?

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
    }

    func show(type: WarningToastViewType = .negative, message: NSAttributedString, dismissAfter: TimeInterval = 3, action: Action? = nil) {
        label.textColor = type.textColor
        view.backgroundColor = type.backgroundColor
        label.attributedText = message
        self.action = action

        UIView.animate(withDuration: 0.5,
            animations: {
                self.alpha = 1
            },
            completion: { _ in
                self.dismissTimer = Timer.scheduledTimer(withTimeInterval: dismissAfter, repeats: false) { [weak self] _ in
                    self?.dismiss()
                }
        })
    }

    @IBAction func tapped(_ sender: Any) {
        dismiss()
        action?()
    }

    private func dismiss() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }

        dismissTimer?.invalidate()
        dismissTimer = nil
    }
}
