//
//  AuthVC.swift
// 

import UIKit

class AuthVC: UIViewController {
    
    @IBOutlet weak var lblOR: UILabel!
    @IBOutlet weak var lblMainUserAccess: UILabel!
    
    @IBOutlet weak var viewFullName: UIView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var tfFullName: UITextField!{
        didSet {tfFullName.configureTextField()}
    }
    
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var tfEmail: UITextField! {
        didSet {tfEmail.configureTextField()}
    }
    
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var lblPassword: UILabel!
    @IBOutlet weak var tfPassword: UITextField! {
        didSet {tfPassword.configureTextField(isSafe: true)}
    }
    
    @IBOutlet weak var viewConfirmPass: UIView!
    @IBOutlet weak var lblConfirmPass: UILabel!
    @IBOutlet weak var tfConfirmPass: UITextField! {
        didSet {tfConfirmPass.configureTextField(isSafe: true)}
    }
    
    @IBOutlet weak var viewUserName: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var tfUserName: UITextField! {
        didSet {tfUserName.configureTextField()}
    }
    
    @IBOutlet weak var viewCheck: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var tvContent: UITextView! {
        didSet { configureTextView(tvContent) }
    }
    
    @IBOutlet weak var viewForgotPass: UIView!
    @IBOutlet weak var btnForgotPass: UIButton!
    
    @IBOutlet weak var btnAuthentication: UIButton! {
        didSet { configureButton(btnAuthentication, bgColor: "7D95BA", titleColor: "FFFFFF") }
    }
    
    @IBOutlet weak var btnGoogle: UIButton! {
        didSet { configureSocialButton(btnGoogle) }
    }
    @IBOutlet weak var btnFacebook: UIButton! {
        didSet { configureSocialButton(btnFacebook) }
    }
    @IBOutlet weak var btnApple: UIButton! {
        didSet { configureSocialButton(btnApple) }
    }
    
    var viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton("")
        viewModel.view = self
        updateUI()
        
        self.tfFullName.delegate = self
        self.tfEmail.delegate = self
        self.tfPassword.delegate = self
        self.tfConfirmPass.delegate = self
        self.tfUserName.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.localization()
    }
    
    @IBAction func btnCheckAction(_ sender: UIButton) {
        viewModel.isChecked.toggle()
        let imageName = viewModel.isChecked ? "tick" : "empty_tick"
        btnCheck.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @IBAction func btnAuthenticationAction(_ sender: UIButton) {
        self.viewModel.consumeAuthAPI()
    }
    
    @IBAction func btnGoogleAction(_ sender: UIButton) {
        viewModel.loginWithSocialMedia(socialMedia: .google)
    }
    
    @IBAction func btnFacebookAction(_ sender: UIButton) {
        viewModel.loginWithSocialMedia(socialMedia: .facebook)
    }
    
    @IBAction func btnAppleAction(_ sender: UIButton) {
        viewModel.loginWithSocialMedia(socialMedia: .apple)
    }
    
    @IBAction func btnForgotPassAction(_ sender: UIButton) {
        let vc = ForgotPasswordVC.instantiate(.Auth)
        self.pushViewController(vc: vc)
    }
}

extension AuthVC {
    private func updateUI() {
        let isLogin = viewModel.authType == .login
        viewConfirmPass.isHidden = isLogin
        viewUserName.isHidden = isLogin
        viewEmail.isHidden = false
        viewPassword.isHidden = false
        viewCheck.isHidden = isLogin
        viewForgotPass.isHidden = !isLogin
        viewFullName.isHidden = isLogin
        lblEmail.font = .font(type: .regular, customSize: iPad ? 22 : 12)
        lblPassword.font = .font(type: .regular, customSize: iPad ? 22 : 12)
        lblFullName.font = .font(type: .regular, customSize: iPad ? 22 : 12)
        lblUserName.font = .font(type: .regular, customSize: iPad ? 22 : 12)
        lblConfirmPass.font = .font(type: .regular, customSize: iPad ? 22 : 12)
        btnForgotPass.titleLabel?.font = .font(type: .bold, customSize: iPad ? 22 : 12)
        btnAuthentication.titleLabel?.font = .font(type: .bold, customSize: iPad ? 26 : 16)


    }
    
    private func localization(){
        let isLogin = viewModel.authType == .login
        lblEmail.text = isLogin ? String(with: .emailUserName) : String(with: .email)
        tfEmail.placeholder = isLogin ? String(with: .emailUsernamePlaceholder) : String(with: .emailPlaceholder)
        
        lblPassword.text = String(with: .password)
        tfPassword.placeholder = String(with: .passwordPlaceholder)
        
        lblConfirmPass.text = String(with: .confirmPassword)
        tfConfirmPass.placeholder = String(with: .confirmpasswordPlaceholder)
        
        lblUserName.text = String(with: .userName)
        tfUserName.placeholder = String(with: .usernamePlaceholder)
        btnAuthentication.setTitle(isLogin ? String(with: .register) : String(with: .login), for: .normal)
        btnAuthentication.setTitle(isLogin ? String(with: .log_in) : String(with: .register), for: .normal)
       
        lblFullName.text = String(with: .fullName)
        tfFullName.placeholder = String(with: .fullnamePlaceholder)
        btnForgotPass.setTitle(isLogin ? String(with: .forgotpassword) : String(with: .forgotpassword), for: .normal)
        lblMainUserAccess.text = String(with: .Main_User_ACCESS)
        lblOR.text = String(with: .or)
//        btnAuthentication.setTitle(String(with: .register), for: .normal)
//        btnAuthentication.setTitle(String(with: .login), for: .normal)

    }
}

// MARK: - UI Configuration
private extension AuthVC {
    func configureSocialButton(_ button: UIButton) {
        button.layer.shadowColor = UIColor(named: "93E9F8")?.cgColor
        button.layer.shadowOffset = CGSize(width: 0.3, height: 2.0)
        button.layer.shadowRadius = 3.0
        button.layer.shadowOpacity = 0.3
        button.layer.masksToBounds = false
        button.layer.cornerRadius = iPad ? 35 : 25
    }
    
    func configureTextView(_ textView: UITextView) {
        textView.delegate = self
        textView.isSelectable = true
        textView.isEditable = false
        textView.delaysContentTouches = false
        textView.isScrollEnabled = false
        let font: UIFont = .font1(customSize: iPad ? 20 : 12)
        let textColor: UIColor = .darkBlue7D95BA ?? UIColor(named: "7D95BA")!
        let textValue = String(format: String(with: .iAgreeTo), String(with: .terms))
        
        let attributedString = NSMutableAttributedString(
            string: textValue,
            attributes: [
                .foregroundColor: textColor,
                .font: font
            ]
        )
        attributedString.addAttribute(
            .link,
            value: "terms://termsofCondition",
            range: (attributedString.string as NSString).range(of: String(with: .terms))
        )
        textView.font = font
        textView.linkTextAttributes = [
            .foregroundColor: textColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        textView.attributedText = attributedString
    }
}

// MARK: - UITextViewDelegate
extension AuthVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == "terms" {
            pushWebViewVC(.terms)
            return false
        }
        return true
    }
}

// MARK: - UITextFieldDelegate
extension AuthVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        let isLogin = viewModel.authType == .login
        if isLogin{
            if textField == tfEmail  {
                tfPassword.becomeFirstResponder()
            } else if textField == tfPassword {
                textField.resignFirstResponder()
            }
        }
        else{
            if textField == tfFullName {
                tfEmail.becomeFirstResponder()
            } else if textField == tfEmail  {
                tfPassword.becomeFirstResponder()
            } else if textField == tfPassword {
                tfConfirmPass.becomeFirstResponder()
            } else if textField == tfConfirmPass {
                tfUserName.becomeFirstResponder()
            } else if textField == tfUserName {
                textField.resignFirstResponder()
            }
        }
        return true
    }
}
