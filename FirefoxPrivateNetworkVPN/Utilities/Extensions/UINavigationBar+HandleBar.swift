//
//  UINavigationBar+HandleBar
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

extension UINavigationBar {

    private static let handleBarTag = "handleBar".hashValue

    @available(iOS 13.0, *)
    var isHandleBarShown: Bool {
        get {
            return handleBarView(from: subviews) != nil
        }

        set(shouldShow) {
            if shouldShow {
                let handleBarView = UIView(frame: CGRect(x: 0, y: 8, width: 32, height: 4))
                handleBarView.tag = Self.handleBarTag
                handleBarView.backgroundColor = UIColor(red: 0.769, green: 0.769, blue: 0.769, alpha: 1)
                handleBarView.layer.cornerRadius = 2
                handleBarView.center.x = center.x

                addSubview(handleBarView)
            } else {
                if let handleBarView = handleBarView(from: subviews) {
                    handleBarView.removeFromSuperview()
                }
            }
        }
    }

    private func handleBarView(from subviews: [UIView]) -> UIView? {
        return subviews.filter { $0.tag == Self.handleBarTag }.first
    }
}
