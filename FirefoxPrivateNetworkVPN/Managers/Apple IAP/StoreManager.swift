//
//  StoreManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation
import StoreKit

protocol StoreManagerDelegate: class {
    func didUploadReceipt()
    func didReceiveError(_ error: Error?)
    func invalidAccount()
}

class StoreManager: NSObject {
    static let shared = StoreManager()
    private let accountManager = DependencyManager.shared.accountManager
    weak var delegate: StoreManagerDelegate?
    private var isUploading: Bool = false

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    // MARK: - Properties

    private var availableProducts = [SKProduct]()
    private var productRequest: SKProductsRequest?

    // MARK: - Request Product Information

    func startProductRequest(with identifiers: [String]) {
        if !availableProducts.isEmpty { return }
        productRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        productRequest?.delegate = self
        productRequest?.start()
    }

    // MARK: - Submit Payment Request

    func buy() {
        if let product = availableProducts.first {
            let payment = SKMutablePayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }

    // MARK: - Restore All Restorable Purchases

    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension StoreManager: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        availableProducts = response.products
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreManager: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                handleFailed(transaction)
            case .restored:
                handleRestored(transaction)
            default:
                break
            }
        }
    }

    // MARK: - Handle Payment Transactions

    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        accountManager.saveIAPEmail()
        uploadReceipt()
    }

    private func handleFailed(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        delegate?.didReceiveError(transaction.error)
    }

    private func handleRestored(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        uploadReceipt()
    }

    private func uploadReceipt() {
        if accountManager.isIAPAccount {
            if !isUploading,
                let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                FileManager.default.fileExists(atPath: appStoreReceiptURL.path),
                let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) {

                isUploading = true
                accountManager.uploadReceipt(receipt: receiptData.base64EncodedString()) { result in
                    self.isUploading = false
                    switch result {
                    case .success:
                        self.delegate?.didUploadReceipt()
                    case .failure(let error):
                        self.delegate?.didReceiveError(error)
                    }
                }
            }
        } else {
            delegate?.invalidAccount()
        }
    }
}
