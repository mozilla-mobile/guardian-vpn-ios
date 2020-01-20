//
//  FormSheetStyleViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

class FormSheetStyleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            presentingViewController?.view.alpha = 0.5
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.view.alpha = 1
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        let closeButton = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItems = [closeButton]
        navigationController?.navigationBar.barTintColor = UIColor.custom(.grey5)
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}
