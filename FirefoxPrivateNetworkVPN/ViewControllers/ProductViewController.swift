//
//  ProductViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

class ProductViewController: UIViewController, Navigating {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var purchaseButton: UIButton!

    // MARK: - Properties
    static var navigableItem: NavigableItem = .product

    // MARK: - Initialization
    init() {
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBarForModalPresentation()
        hideNavigationBarBottomLine()
        setCornerRadius()
    }

    private func setCornerRadius() {
        backgroundView.cornerRadius = UIScreen.isiPad ? 8 : 4
        purchaseButton.cornerRadius = purchaseButton.frame.height/10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = false
        }
    }

    @IBAction func purchase(_ sender: UIButton) {

    }

    @IBAction func restore(_ sender: UIButton) {

    }
}
