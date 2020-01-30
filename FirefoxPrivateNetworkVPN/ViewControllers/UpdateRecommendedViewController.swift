//
//  UpdateRecommendedViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

class UpdateRecommendedViewController: UIViewController, Navigating {
    static var navigableItem: NavigableItem = .recommendedUpdate

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var connectionSubtitleLabel: UILabel!
    @IBOutlet private weak var updateNowButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        updateNowButton.setBackgroundImage(UIImage.image(with: UIColor.custom(.blue80)), for: .highlighted)
        setLocalizedStrings()
    }

    private func setupNavigationBar() {
        setupNavigationBarForModalPresentation()
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = false
        }
    }

    @IBAction private func updateNowButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.navigate(to: .appStore)
        }
    }

    // MARK: - Setup
    private func setLocalizedStrings() {
        titleLabel.text = LocalizedString.updateRecommended.value
        subtitleLabel.text = LocalizedString.updateRecommendedSubtitle.value
        connectionSubtitleLabel.text = LocalizedString.updateRecommendedConnection.value
        updateNowButton.titleLabel?.text = LocalizedString.toastUpdateNow.value
    }
}
