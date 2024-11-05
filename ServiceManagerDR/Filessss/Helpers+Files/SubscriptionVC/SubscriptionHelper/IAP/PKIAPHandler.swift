//
//  PKIAPHandler.swift
//

import UIKit
import StoreKit

enum PKIAPHandlerAlertType {
    case setProductIds
    case disabled
    case restored
    case purchased
    
    var message: String{
        switch self {
        case .setProductIds: return "Product ids not set, call setProductIds method!"
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        }
    }
}


enum PurchaseProduct: String, CaseIterable {
    case kMonthlyPlan = "com.uowemonthlysubscription.app"
//    case kMonthlyPlan = "com.package.monthly"
    case Freetrial = ""
    case MonthlyType = "Monthly"
    case YearlyType = "Yearly"
    case restoreMonthly = "restoreMonthly"//For restore scenario where we need to buy plan
    case source = "iOS"
}


class PKIAPHandler: NSObject {
    
    //MARK:- Shared Object
    static let shared = PKIAPHandler()
    private override init() { }
    
    //MARK:- Properties
    //MARK:- Private
    fileprivate var productIds = [String]()
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var fetchProductComplition: (([SKProduct])->Void)?
    
    fileprivate var productToPurchase: SKProduct?
    fileprivate var purchaseProductComplition: ((PKIAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)?
    private var restoreCompletion: ((Result<SKPaymentTransaction, Error>) -> Void)?
    //MARK:- Public
    var isLogEnabled: Bool = true
    
    //MARK:- Methods
    //MARK:- Public
    
    //Set Product Ids
    func setProductIds(ids: [String]) {
        self.productIds = ids
    }
    
    // RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchase(product: SKProduct, complition: @escaping ((PKIAPHandlerAlertType, SKProduct?, SKPaymentTransaction?)->Void)) {
        //        Spinner.hide()
        
        
        self.purchaseProductComplition = complition
        self.productToPurchase = product
        
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            log("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            debugPrint("Product id from PKIAP =>", productID)
        }
        else {
            complition(PKIAPHandlerAlertType.disabled, nil, nil)
        }
    }
    
    // RESTORE PURCHASE
    // Restore previous purchases
    func restorePurchases(completion: @escaping (Result<SKPaymentTransaction, Error>) -> Void) {
        restoreCompletion = completion
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
   
    
    // FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(complition: @escaping (([SKProduct])->Void)){
        
        self.fetchProductComplition = complition
        // Put here your IAP Products ID's
        if self.productIds.isEmpty {
            log(PKIAPHandlerAlertType.setProductIds.message)
            fatalError(PKIAPHandlerAlertType.setProductIds.message)
        }
        else {
            productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    //MARK:- Private
    fileprivate func log <T> (_ object: T) {
        if isLogEnabled {
            NSLog("\(object)")
        }
    }
}

//MARK:- Product Request Delegate and Payment Transaction Methods
extension PKIAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    // REQUEST IAP PRODUCTS
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            fetchProductComplition?(response.products)
        } else {
            log("No products found")
            fetchProductComplition?([])
        }
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
         for transaction in transactions {
             switch transaction.transactionState {
             case .purchased:
                 if let originalTransaction = transaction.original {
                          // Handle the case where the user is already subscribed
                          log("User is already subscribed")
                     print("User is already subscribed Manage OKay is there")
                     self.stopIndicator()
                     self.handleAlreadySubscribed()
                      } else {
                          // Handle a new purchase
                          log("Product purchase done")
                          SKPaymentQueue.default().finishTransaction(transaction)
                          purchaseProductComplition?(.purchased, productToPurchase, transaction)
                      }
                      purchaseProductComplition = nil
                      break
             case .failed:
                 self.log("Product purchase failed")
                 self.stopIndicator()
                 SKPaymentQueue.default().finishTransaction(transaction)
                 break
             case .restored:
                 log("Product restored")
                 SKPaymentQueue.default().finishTransaction(transaction)
                 restoreCompletion?(.success(transaction))
                 restoreCompletion = nil
                 break
             default:
                 self.stopIndicator()
                 break
             }
         }
     }
    
    
    @objc func handleAlreadySubscribed() {
        UIViewController().showCustomAlert(title: Bundle.appName, message: String(with: .restoreSubscription), okTitle: String(with: .alertOK), cancelTitle: String(with: .alertCancel),popViewType: .okOnly) { okPressed, isCancel in
            print("")
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
         if queue.transactions.isEmpty {
             restoreCompletion?(.failure(NSError(domain: "No transactions to restore", code: 0, userInfo: nil)))
             print("No transactions to restore")
             showToast(message: String(with: .noTransactionToRestore))
         } else {
             for transaction in queue.transactions where transaction.transactionState == .restored {
                 restoreCompletion?(.success(transaction))
                 print("transactions restore Successfull")
             }
         }
         restoreCompletion = nil
     }

     func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
         restoreCompletion?(.failure(error))
         restoreCompletion = nil
     }
}
