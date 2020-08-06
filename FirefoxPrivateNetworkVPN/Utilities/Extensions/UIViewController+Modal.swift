//
//  UIViewController+Modal
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

extension UIViewController {

    @available(iOS 13.0, *)
    var isPresentingViewControllerDimmed: Bool {
        get {
            guard let presentingViewController = presentingViewController else { return false }
            return presentingViewController.view.alpha < 1.0
        }

        set(shouldDimPresentingViewController) {
            presentingViewController?.view.alpha = shouldDimPresentingViewController ? 0.5 : 1
        }
    }

    func setupNavigationBarForModalPresentation() {
        let closeButton = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(closeModal))
        navigationItem.leftBarButtonItems = [closeButton]
        navigationController?.navigationBar.barTintColor = UIColor.custom(.grey5)

        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.isHandleBarShown = true
        }
    }

    @objc func closeModal() {
        dismiss(animated: true, completion: nil)
    }

    func hideNavigationBarBottomLine() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}
