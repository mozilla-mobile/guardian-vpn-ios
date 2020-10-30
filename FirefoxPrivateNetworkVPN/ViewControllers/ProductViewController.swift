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

    private let accountManager = DependencyManager.shared.accountManager

    // MARK: - Properties
    static var navigableItem: NavigableItem = .product
    private lazy var loadingAlert: UIAlertController = {
        let alert = UIAlertController(title: nil, message: LocalizedString.loadingSpinner.value, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        indicator.style = .gray
        indicator.startAnimating()
        alert.view.addSubview(indicator)
        return alert
    }()

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
        StoreManager.shared.delegate = self
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
        present(loadingAlert, animated: false, completion: nil)
        StoreManager.shared.buy()
    }

    @IBAction func restore(_ sender: UIButton) {
        present(loadingAlert, animated: false, completion: nil)
        StoreManager.shared.restore()
    }
}

extension ProductViewController: StoreManagerDelegate {

    func didUploadReceipt() {
        accountManager.handleAfterPurchased { loginResult in
            switch loginResult {
            case .success:
                self.navigate(to: .home, context: .iapSucceed)
            case .failure(let error):
                let context: NavigableContext = error == .maxDevicesReached ? .maxDevicesReached : .error(error)
                self.navigate(to: .home, context: context)
            }
            self.loadingAlert.dismiss(animated: false, completion: nil)
        }
    }

    func didReceiveError(_ error: Error?) {
        if let error = error {
            self.navigate(to: .home, context: .error(error))
        }
        loadingAlert.dismiss(animated: false, completion: nil)
    }

    func invalidAccount() {
        loadingAlert.dismiss(animated: false, completion: nil)

        let alert = UIAlertController(title: LocalizedString.errorInvalidAccount.value, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LocalizedString.confirmInvalidAccount.value, style: .default) { _ in /* Do nothing */ })
        present(alert, animated: true, completion: nil)
    }
}
