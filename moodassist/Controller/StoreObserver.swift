/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implements the SKPaymentTransactionObserver protocol. Handles purchasing and restoring products using paymentQueue:updatedTransactions:.
*/

import StoreKit
import Foundation

protocol StoreObserverDelegate: AnyObject {
	/// Tells the delegate that the restore operation was successful.
	func storeObserverRestoreDidSucceed()

	/// Provides the delegate with messages.
	func storeObserverDidReceiveMessage(_ message: String)
}

class StoreObserver: NSObject {
	// MARK: - Types

	static let shared = StoreObserver()

	// MARK: - Properties

	/**
	Indicates whether the user is allowed to make payments.
	- returns: true if the user is allowed to make payments and false, otherwise. Tell StoreManager to query the App Store when the user is
	allowed to make payments and there are product identifiers to be queried.
	*/
	var isAuthorizedForPayments: Bool {
		return SKPaymentQueue.canMakePayments()
	}

	/// Keeps track of all purchases.
	var purchased = [SKPaymentTransaction]()

	/// Keeps track of all restored purchases.
	var restored = [SKPaymentTransaction]()

	/// Indicates whether there are restorable purchases.
	fileprivate var hasRestorablePurchases = false

	weak var delegate: StoreObserverDelegate?

	// MARK: - Initializer

	private override init() {}

	// MARK: - Submit Payment Request

	/// Create and add a payment request to the payment queue.
	func buy(_ product: SKProduct) {
		let payment = SKMutablePayment(product: product)
		SKPaymentQueue.default().add(payment)
	}
	
	func displayBuy(){
		//the string is the product id registered at apple in app store connect
		StoreManager.shared.startProductRequest(with: ["premium"])
	}
	
	func buyPremium() {
		if let premium = StoreManager.shared.premiumProduct {
			buy(premium)
		}
	}

	// MARK: - Restore All Restorable Purchases

	/// Restores all previously completed purchases.
	func restore() {
		//check the included receipt to obtain the purchased date
		if let receiptURL = Bundle.main.appStoreReceiptURL {
			do {
				let data = try Data(contentsOf: receiptURL)
				self.verifyIfPurchasedBeforeFreemium(sandboxStoreURL, data)
			} catch {
				print(error.localizedDescription)
				return
			}
		}
		
		//this code was copied from the example code
		if !restored.isEmpty {
			restored.removeAll()
		}
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
	
	private let productionStoreURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
	private let sandboxStoreURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!

	private func verifyIfPurchasedBeforeFreemium(_ storeURL: URL, _ receipt: Data) {
		do {
			let requestContents = ["receipt-data": receipt.base64EncodedString()]
			let requestData = try JSONSerialization.data(withJSONObject: requestContents, options: [])

			var storeRequest = URLRequest(url: storeURL)
			storeRequest.httpMethod = "POST"
			storeRequest.httpBody = requestData

			URLSession.shared.dataTask(with: storeRequest) { (data, response, error) in
				DispatchQueue.main.async {
					if data != nil {
						do {
							let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any?]

							if let statusCode = jsonResponse["status"] as? Int {
								if statusCode == 21007 {
									print("Switching to test against sandbox")
									self.verifyIfPurchasedBeforeFreemium(self.sandboxStoreURL, receipt)
								}
							}

							if let receiptResponse = jsonResponse["receipt"] as? [String: Any?], let originalVersion = receiptResponse["original_application_version"] as? String {
								if originalVersion == "1.0.1" {
									// Update to full paid version of app
									//UserDefaults.standard.set(true, forKey: upgradeKeys.isUpgraded)
								}
							}
						} catch {
							print("Error: " + error.localizedDescription)
						}
					}
				}
				}.resume()
		} catch {
			print("Error: " + error.localizedDescription)
		}
	}

	// MARK: - Handle Payment Transactions

	/// Handles successful purchase transactions.
	fileprivate func handlePurchased(_ transaction: SKPaymentTransaction) {
		purchased.append(transaction)
		print("\(Messages.deliverContent) \(transaction.payment.productIdentifier).")

		// Finish the successful transaction.
		SKPaymentQueue.default().finishTransaction(transaction)
	}

	/// Handles failed purchase transactions.
	fileprivate func handleFailed(_ transaction: SKPaymentTransaction) {
		var message = "\(Messages.purchaseOf) \(transaction.payment.productIdentifier) \(Messages.failed)"

		if let error = transaction.error {
			message += "\n\(Messages.error) \(error.localizedDescription)"
			print("\(Messages.error) \(error.localizedDescription)")
		}

		// Do not send any notifications when the user cancels the purchase.
		if (transaction.error as? SKError)?.code != .paymentCancelled {
			DispatchQueue.main.async {
				self.delegate?.storeObserverDidReceiveMessage(message)
			}
		}
		// Finish the failed transaction.
		SKPaymentQueue.default().finishTransaction(transaction)
	}

	/// Handles restored purchase transactions.
	fileprivate func handleRestored(_ transaction: SKPaymentTransaction) {
		hasRestorablePurchases = true
		restored.append(transaction)
		print("\(Messages.restoreContent) \(transaction.payment.productIdentifier).")

		DispatchQueue.main.async {
			self.delegate?.storeObserverRestoreDidSucceed()
		}
		// Finishes the restored transaction.
		SKPaymentQueue.default().finishTransaction(transaction)
	}
	
}

// MARK: - SKPaymentTransactionObserver

/// Extends StoreObserver to conform to SKPaymentTransactionObserver.
extension StoreObserver: SKPaymentTransactionObserver {
	/// Called when there are transactions in the payment queue.
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			switch transaction.transactionState {
			case .purchasing: break
			// Do not block your UI. Allow the user to continue using your app.
			case .deferred: print(Messages.deferred)
			// The purchase was successful.
			case .purchased: handlePurchased(transaction)
			// The transaction failed.
			case .failed: handleFailed(transaction)
			// There are restored products.
			case .restored: handleRestored(transaction)
			@unknown default: fatalError("\(Messages.unknownDefault)")
			}
		}
	}

	/// Logs all transactions that have been removed from the payment queue.
	func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
		for transaction in transactions {
			print ("\(transaction.payment.productIdentifier) \(Messages.removed)")
		}
	}

	/// Called when an error occur while restoring purchases. Notify the user about the error.
	func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
		if let error = error as? SKError, error.code != .paymentCancelled {
			DispatchQueue.main.async {
				self.delegate?.storeObserverDidReceiveMessage(error.localizedDescription)
			}
		}
	}

	/// Called when all restorable transactions have been processed by the payment queue.
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		print(Messages.restorable)

		if !hasRestorablePurchases {
			DispatchQueue.main.async {
				self.delegate?.storeObserverDidReceiveMessage(Messages.noRestorablePurchases)
			}
		}
	}
	
}

