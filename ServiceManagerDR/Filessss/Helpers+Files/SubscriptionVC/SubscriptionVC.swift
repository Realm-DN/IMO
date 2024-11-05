//
//  SubscriptionVC.swift
// 

import UIKit
import StoreKit
import SafariServices

class SubscriptionVC: UIViewController {
    @IBOutlet weak var navViewContainer: UIView! {
        didSet {
            navViewContainer.configureNavViewContainer()
        }
    }
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var textVwContent: UITextView!
    
    
    
    @IBOutlet weak var btnMonthly: UIButton!
    
    @IBOutlet weak var lblDaysLeft: UILabel!
    @IBOutlet weak var btnFree: UIButton!
    @IBOutlet weak var vwYearlyPlan: UIView!
    @IBOutlet weak var vwMonthlyPlan: UIView!
//    @IBOutlet weak var vwFreeTrial: UIView!
//    @IBOutlet weak var btnSubscribeAOut: UIButton!
    @IBOutlet weak var btnSubscribe: UIButton!{
        didSet{
            configureButton(btnSubscribe, bgColor: "7D95BA", titleColor: "FFFFFF")
        }
    }
    
    @IBOutlet weak var lblExpiryStatus: UILabel!
//    @IBOutlet weak var lblYearlyPriceOut: UILabel!
    @IBOutlet weak var lblMonthlyPriceOut: UILabel!
    
    @IBOutlet weak var btnRestore: UIButton!{
        didSet{
            btnRestore.isUserInteractionEnabled = true
            configureButton(btnRestore, bgColor: "7D95BA", titleColor: "FFFFFF")
        }
    }
    
    var selectedIndex = -1
    var subscriptionVM = SubscriptionViewModel()
    var kBasicSetting = UserSingleton.shared.getAppSettingsData()
    //MARK: - **************** IAP 1****************
    let productIDs = [PurchaseProduct.kMonthlyPlan.rawValue]
    var arrOfProducts = [SKProduct]()
    //**************** IAP ****************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - **************** IAP 2 ****************
        self.purchaseInit()
        //MARK: - **************** IAP ****************
        self.setupUI()
        self.setupNavigationBar()
        self.termConditionSetup()
        self.subscriptionVM.getSubscriptionDetailsApi { status, msg in
            if status == false{
             showToast(message: msg)
            }else{
                self.setupView(model: self.subscriptionVM.model)
            }
        }
    }
    
    
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.performSegueToReturnBack()
    }
    
    func setupView(model:SubscriptionModel?){
        if model?.data?.plan_status ?? false == false{
            self.vwMonthlyPlan.backgroundColor = .lightGray
            self.vwYearlyPlan.backgroundColor = appColor
            self.btnFree.isUserInteractionEnabled = false
            self.btnSubscribe.isUserInteractionEnabled = true
            self.btnSubscribe.alpha = 1
            self.lblDaysLeft.text = String(with: .expired)
            self.viewSelections(sender: self.btnMonthly)
            self.lblExpiryStatus.isHidden = true
            if model?.data?.is_trial_period ??  false == false{
                self.lblExpiryStatus.isHidden = false
                self.lblExpiryStatus.text = "  " + String(with: .subscriptionExpiredOn) + " : \(model?.data?.modifiedCreatedDate ?? "")"
            }
        }else{
            if model?.data?.is_trial_period ?? false == true{
                self.vwMonthlyPlan.backgroundColor = appColor
                self.vwYearlyPlan.backgroundColor = .lightGray
                self.btnFree.isUserInteractionEnabled = true
                self.lblDaysLeft.text = String(format: String(with: .daysLeft), "\(model?.data?.days_left ?? 0)")
                self.btnSubscribe.setTitle(String(with: .subscribe) , for: .normal)
                self.btnSubscribe.isUserInteractionEnabled = true
                self.lblExpiryStatus.isHidden = true
                self.btnSubscribe.alpha = 1
                self.viewSelections(sender: self.btnFree)
            }else{
                self.btnFree.isUserInteractionEnabled = false
                self.vwMonthlyPlan.backgroundColor = .lightGray
                self.vwYearlyPlan.backgroundColor = appColor
                self.lblDaysLeft.text = String(with: .expired)
                self.btnSubscribe.isUserInteractionEnabled = false
                self.btnSubscribe.alpha = 0.5
                self.btnSubscribe.setTitle(String(with: .subscribed), for: .normal)
#if DEBUG
                self.lblExpiryStatus.text = "  " + String(with: .subscriptionWillExpireOn) + " : \(model?.data?.modifiedCreatedDate ?? "")"
#else
                self.lblExpiryStatus.text = "  " + String(with: .subscriptionWillExpireOn) + " : \(model?.data?.modifiedCreatedDate ?? "")"
#endif
                self.lblExpiryStatus.isHidden = false
                self.viewSelections(sender: self.btnMonthly)
                
               
            }
        }
    }
    
    func setupUI() {
        self.btnSubscribe.layer.cornerRadius = 6.0
        self.btnRestore.layer.cornerRadius = 6.0
        self.vwYearlyPlan.layer.cornerRadius = 10.0
        self.vwYearlyPlan.layer.borderWidth = 1.0
        self.vwYearlyPlan.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        
        self.vwMonthlyPlan.layer.cornerRadius = 10.0
        self.vwMonthlyPlan.layer.borderWidth = 1.0
        self.vwMonthlyPlan.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
    }
    
    func setupNavigationBar (){
        self.navigationController?.isNavigationBarHidden = true
        self.lblTitle.text = String(with: .subscriptions).uppercased()
    }
    
    @objc func action_NavLeftBarBtn () {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubscribeAct(_ sender: Any) {
        self.buySubscription()
    }
    
    @IBAction func btMonthlyPlanAct(_ sender: Any) {
        if let btn = sender as? UIButton {
            self.viewSelections(sender: btn)
        }
    }
    
    @IBAction func btnFreePlanAct(_ sender: Any) {
        if let btn = sender as? UIButton {
            self.viewSelections(sender: btn)
        }
    }
    
    
    @IBAction func restorePurchaseBtnTapped(_ sender: UIButton) {
        PKIAPHandler.shared.restorePurchase()
    }
    
    func viewSelections(sender:UIButton) {
        if sender.tag == 10 {
            //monthly
            self.vwMonthlyPlan.backgroundColor = appColor
            self.vwYearlyPlan.backgroundColor = .lightGray
            selectedIndex = 1
        } else if sender.tag == 20 {
            //yearly
            self.vwMonthlyPlan.backgroundColor = .lightGray
            self.vwYearlyPlan.backgroundColor = appColor
            selectedIndex = 2
        }
    }
}

//MARK: - **************** IAP 3****************
extension SubscriptionVC {
    func purchaseInit() {
        PKIAPHandler.shared.setProductIds(ids: self.productIDs)
        PKIAPHandler.shared.fetchAvailableProducts { [weak self](products)   in
            guard let subPlan = self else { return }
            subPlan.arrOfProducts = products
            print(products)
            DispatchQueue.main.async {
                subPlan.updateSubscriptionPakages()
            }
        }
    }
    
    func updateSubscriptionPakages() {
        for item in arrOfProducts {
            let price = item.localizedPrice()
            if item.productIdentifier == PurchaseProduct.kMonthlyPlan.rawValue {
                self.lblMonthlyPriceOut.text = String(format: String(with: .payMonth), price ?? "")
                debugPrint("Price for One Month Plan \(price ?? "")")
            }else {
                debugPrint("Price for Life Time Plan \(price ?? "")")
//                self.lblYearlyPriceOut.text = String(format: String(with: .payAnnual), price ?? "")
            }
        }
    }
    
    func buySubscription() {
        if arrOfProducts.isEmpty {
//            self.view.showToastonTop(message: UIConstants.somethingWrong.localized())
        } else if selectedIndex == 1 {
            //monthly
            self.buyPlan(selectedPlan: PurchaseProduct.kMonthlyPlan.rawValue)
        }else{
            showToast(message: String(with: .plsSelectPlan) )
        }
    }
    
    func buyPlan(selectedPlan:String) {
        if let index = self.arrOfProducts.firstIndex(where: {$0.productIdentifier == selectedPlan}) {
            self.startIndicator()
            PKIAPHandler.shared.purchase(product: self.arrOfProducts[index]) { (alert, product, transaction) in
                self.stopIndicator()
                if (product == nil) && (transaction == nil) {
                    showToast( message: alert.message)
                } else {
                    //                    self.stopIndicator()
                    let receiptPath = Bundle.main.appStoreReceiptURL?.path
                    if FileManager.default.fileExists(atPath: receiptPath!) {
                        var receiptData:NSData?
                        do {
                            receiptData = try NSData(contentsOf: Bundle.main.appStoreReceiptURL!, options: NSData.ReadingOptions.alwaysMapped)
                        } catch {
                            self.stopIndicator()
                            print("ERROR: " + error.localizedDescription)
                        }
                        let base64encodedReceipt = receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithCarriageReturn)
                        debugPrint(base64encodedReceipt!)
                        let type = "monthly"
                        
                        let params : [String : Any] = [ "payment_with": "apple" ,
                                                        "product_id" : selectedPlan,
                                                        "latest_receipt": base64encodedReceipt ?? "",
                                                        "local_amount":  "\(self.arrOfProducts[index].localizedPrice() ?? "")",
                                                        "local_currency": "\(self.arrOfProducts[index].priceLocale.currencyCode ?? "")",
                                                        "purchase_type": "purchased"
                        ]
                        debugPrint(params)
                        if self.subscriptionVM.isLoading == false{
                            self.subscriptionVM.isLoading = true
                            self.subscriptionVM.callWebhookApi(param:params) {_,_ in
                                self.subscriptionVM.isLoading = false
                                self.setupView(model: self.subscriptionVM.model)
                                
                            }
                        }
                    }
                }
            }
        }
    }
}

extension SKProduct {
    public func priceString() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 2
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
    
    public func localizedPrice() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}

extension SubscriptionVC {
    func termConditionSetup1() {
        let text = String(format: String(with: .subscriptionText), String(with: .privacyPolicy) , String(with: .terms))
        
        let attributedString = NSMutableAttributedString(string: text)
        
        let privacyPolicyRange = (text as NSString).range(of: String(with: .privacyPolicy))
        let termsConditionsRange = (text as NSString).range(of: String(with: .terms))
        
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.link,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        attributedString.addAttributes(linkAttributes, range: privacyPolicyRange)
        attributedString.addAttribute(.link, value: kBasicSetting?.privacy_policy ?? "", range: privacyPolicyRange)
        
        attributedString.addAttributes(linkAttributes, range: termsConditionsRange)
        attributedString.addAttribute(.link, value: kBasicSetting?.terms_conditions ?? "", range: termsConditionsRange)
        
        textVwContent.textColor = UIColor.black
        textVwContent.attributedText = attributedString
        
        textVwContent.textAlignment = .center
        textVwContent.font = .font_size(size: iPad ? 20 : 14)
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTextView(gesture:)))
        textVwContent.addGestureRecognizer(tapGesture)
        textVwContent.isUserInteractionEnabled = true
    }
    
    @objc func tapTextView(gesture: UITapGestureRecognizer) {
        let text = textVwContent.text ?? ""
        let privacyRange = (text as NSString).range(of: String(with: .privacyPolicy))
        let termsRange = (text as NSString).range(of: String(with: .terms))
        
        if gesture.didTapAttributedTextInTextView(textView: textVwContent, inRange: privacyRange) {
            pushWebViewVC(.privacy)
        } else if gesture.didTapAttributedTextInTextView(textView: textVwContent, inRange: termsRange) {
            pushWebViewVC(.terms)
        } else {
            debugPrint("Tapped none")
        }
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInTextView(textView: UITextView, inRange targetRange: NSRange) -> Bool {
        let layoutManager = textView.layoutManager
        var location = self.location(in: textView)
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        let characterIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return characterIndex >= targetRange.location && characterIndex < targetRange.location + targetRange.length
    }
}

extension SubscriptionVC : UITextViewDelegate{
    func termConditionSetup() {
        let text = String(with: .subscriptionDesc)
        configTermsTxtView(txtViewTerms: textVwContent,text:text)
    }
    
    func attributedTextConversion(string: String)->NSMutableAttributedString{
        
       
        
        
        let selectedColor = appColor
        
        let font = UIFont(name: "SFProText-SemiBold", size: 14) ?? UIFont.systemFont(ofSize: 14 , weight: .medium)
        let attributedString = NSMutableAttributedString(string: string,attributes: [NSAttributedString.Key.foregroundColor: (traitCollection.isLightMode ? selectedColor : selectedColor) ,NSAttributedString.Key.font : font])
        
       
        
        return attributedString
    }
    func configTermsTxtView(txtViewTerms:UITextView,text:String){
        
        let textValue =  String(format: String(with: .termsAndPrivacy), String(with: .terms), String(with: .privacyPolicy))
        
        let font = UIFont(name: "SFProText-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14 , weight: .medium)
        let attributedString = NSMutableAttributedString(string: textValue ,attributes: [NSAttributedString.Key.foregroundColor: (traitCollection.isLightMode ? UIColor.black : UIColor.white) ,NSAttributedString.Key.font : font])
        

        
        attributedString.addAttribute(.link, value: "terms://termsofCondition", range: (attributedString.string as NSString).range(of: String(with: .terms)))
        
        attributedString.addAttribute(.link, value: "privacy://privacypolicy", range: (attributedString.string as NSString).range(of: String(with: .privacyPolicy)))
        
//        let finalString = NSMutableAttributedString(string: text ,attributes: [NSAttributedString.Key.foregroundColor: (traitCollection.isLightMode ? UIColor.black : UIColor.white) ,NSAttributedString.Key.font : font])
        
        let finalString = NSMutableAttributedString(string: "" ,attributes: [NSAttributedString.Key.foregroundColor: (traitCollection.isLightMode ? UIColor.black : UIColor.white) ,NSAttributedString.Key.font : font])
        
        let pointHeading = attributedTextConversion(string: String(with: .premiumFeatureNew) + ": \n\n")
        let attributedStringPoints = NSMutableAttributedString()
        
        let point1 = attributedTextConversion(string:" • " + String(with: .feature1) + "\n")
        let point2 = attributedTextConversion(string:" • " + String(with: .feature2) + "\n")
        let point3 = attributedTextConversion(string:" • " + String(with: .feature3) + "\n")
//        let point4 = attributedTextConversion(string:" • " + String(with: .feature4) + "\n")
        
        attributedStringPoints.append(point1)
        attributedStringPoints.append(point2)
        attributedStringPoints.append(point3)
//        attributedStringPoints.append(point4)
        
        
        finalString.append(pointHeading)
        
        let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.headIndent = 15 // Adjust head indent to align text after bullet
                paragraphStyle.firstLineHeadIndent = 0
        
        
//        let text = attributedStringPoints.string
//        if let range = finalString.string.range(of:text) {
//            let nsRange = NSRange(range, in: finalString.string)
        attributedStringPoints.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedStringPoints.length))
//        }
        
        finalString.append(attributedStringPoints)
        finalString.append(NSAttributedString(string: "\n\n"))
        let description = NSMutableAttributedString(string: text ,attributes: [NSAttributedString.Key.foregroundColor: (traitCollection.isLightMode ? UIColor.black : UIColor.white) ,NSAttributedString.Key.font : font])
        finalString.append(description)
        finalString.append(attributedString)
        
        txtViewTerms.font = font
        txtViewTerms.linkTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.hexStringToUIColor(hex:  "#0F5FA8"),NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue]
        
       
        
        txtViewTerms.attributedText = finalString
        txtViewTerms.delegate = self
        txtViewTerms.isSelectable = true
        txtViewTerms.isEditable = false
        txtViewTerms.delaysContentTouches = false
        txtViewTerms.isScrollEnabled = false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL.scheme == "terms" {
            pushWebViewVC(.terms)
            return false
        } else  if URL.scheme == "privacy"{
            pushWebViewVC(.privacy)
            return false
        }
        return true
    }
}
