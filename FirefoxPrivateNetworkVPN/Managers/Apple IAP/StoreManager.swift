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
    func didReceiveProducts(_ products: [SKProduct])
    func didReceiveError(_ error: Error)
}

class StoreManager: NSObject {

    static let shared = StoreManager()

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    // MARK: - Properties

    private var availableProducts = [SKProduct]()
    private var productRequest: SKProductsRequest?

    weak var delegate: StoreManagerDelegate?

    // MARK: - Request Product Information

    func startProductRequest(with identifiers: [String]) {
        productRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        productRequest?.delegate = self
        productRequest?.start()
    }

    // MARK: - Submit Payment Request

    func buy(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    // MARK: - Restore All Restorable Purchases

    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension StoreManager: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            availableProducts = response.products
            DispatchQueue.main.async {
                self.delegate?.didReceiveProducts(response.products)
            }
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.delegate?.didReceiveError(error)
        }
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreManager: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("*** purchasing")
            case .deferred:
                print("*** deferred")
            case .purchased:
                print("*** purchased")
                handlePurchased(transaction)
            case .failed:
                print("*** failed")
                handleFailed(transaction)
            case .restored:
                print("*** restored")
            @unknown default:
                print("*** Unknown payment transaction case")
            }
        }
    }

    // MARK: - Handle Payment Transactions

    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        print("Deliver content for \(transaction.payment.productIdentifier).")

        SKPaymentQueue.default().finishTransaction(transaction)

        getReceipt()
    }

    private func getReceipt() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                print("*** receipt: \(receiptString)")
            } catch {
                print("Couldn't read receipt data with error: \(error.localizedDescription)")
            }
        } else {
            print("[ERROR] get receipt failed")
        }
    }

    private func handleFailed(_ transaction: SKPaymentTransaction) {
        var message = "Purchase of \(transaction.payment.productIdentifier) failed"

        if let error = transaction.error {
            message += "\nError: \(error.localizedDescription)"
            print("Error: \(error.localizedDescription)")
        }

        if (transaction.error as? SKError)?.code != .paymentCancelled {
            print("[ERROR] purchase failed: \(message)")
        }

        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func handleRestored(_ transaction: SKPaymentTransaction) {
        print("Restore content for \(transaction.payment.productIdentifier).")

        // Finishes the restored transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
