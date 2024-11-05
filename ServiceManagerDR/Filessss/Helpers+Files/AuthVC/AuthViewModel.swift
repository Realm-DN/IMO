//
//  AuthViewModel.swift
//

import AuthenticationServices
import GoogleSignIn

class AuthViewModel: NSObject {
    weak var view: AuthVC?
    var isChecked: Bool = false
    var authType: AuthType?
    var storeSocialInfo: SocialInfo?
    var storeLoginInfo: LoginInfo?
    var storeRegisterInfo: RegisterInfo?
    
    // MARK: - Authentication
    func consumeAuthAPI(){
        guard let authType = authType else { return }
        switch authType {
        case .login:  loginHit()
        case .register: registerHit()
        }
    }
    
    private func loginHit() {
        if isValidateLogin() { callAuthAPI(for: .login) }
    }
    
    private func registerHit() {
        if isValidateRegister() { callAuthAPI(for: .signup) }
    }
    
    func isValidateLogin()-> Bool{
        guard let username = self.view?.tfEmail.text, !username.isEmpty else {
            showToast(message: String(with: .alertEnterEmail_Username))
            return false
        }
        guard let password = self.view?.tfPassword.text, !password.isEmpty else {
            showToast(message: String(with: .alertEnterPassword))
            return false
        }
        self.storeLoginInfo = LoginInfo(email: username, password: password)
        return true
    }
 
    func isValidateRegister() -> Bool {
        let validations: [(Bool, String)] = [
            (isNotEmpty(self.view?.tfFullName.text?.trimmed().lowercased()), String(with: .alertEnterFullName)),
            (isNotEmpty(self.view?.tfEmail.text?.trimmed().lowercased()), String(with: .alertEnterEmail)),
            (isValidEmail(email: self.view?.tfEmail.text?.trimmed().lowercased() ?? ""), String(with: .alertValidEmail)),
            (isNotEmpty(self.view?.tfPassword.text), String(with: .alertEnterPassword)),
            (isValidPassword(password: self.view?.tfPassword.text ?? ""), String(with: .alertEnterValidPassword)),
            (isNotEmpty(self.view?.tfConfirmPass.text), String(with: .alertConfPass)),
            (passwordSame(password: self.view?.tfPassword.text ?? "", confirmPassword: self.view?.tfConfirmPass.text ?? ""),String(with: .alertConfirmPassNotMatch)),
            (isNotEmpty(self.view?.tfUserName.text), String(with: .alertEnterUserName)),
            (self.isChecked, String(with: .alertTermsOfUse))
        ]
        if let failedValidation = validations.first(where: { !$0.0 }) {
            showToast(message: failedValidation.1)
            return false
        }
        
        let email = self.view?.tfEmail.text?.trimmed().lowercased()
        let password = self.view?.tfPassword.text ?? ""
        let username = self.view?.tfUserName.text ?? ""
        let full_name = self.view?.tfFullName.text ?? ""
        
        self.storeRegisterInfo = RegisterInfo(email: email, password: password, username: username, full_name: full_name)
        return true
    }
    
//    func callAuthAPI() {
        private func callAuthAPI(for endpoint: APIEndpoint) {
        guard let authType = authType else { return }
        
        let params: Parameters
//        let api: APIEndpoint

        switch authType {
        case .login:
            guard let loginInfo = self.storeLoginInfo else { return }
            params = [
                ParameterKeyNames.Auth.userName: loginInfo.email ?? "",
                ParameterKeyNames.Auth.password: loginInfo.password ?? ""
            ]
        case .register:
            guard let registerInfo = self.storeRegisterInfo else { return }
            params = [
                ParameterKeyNames.Auth.full_name: registerInfo.full_name ?? "",
                ParameterKeyNames.Auth.email: registerInfo.email ?? "",
                ParameterKeyNames.Auth.password: registerInfo.password ?? "",
                ParameterKeyNames.Auth.userName: registerInfo.username ?? ""
            ]
        }
        
        serviceManager.requestAPI(apiEndPoint: endpoint, parameters: params) { (result: Result<UserModel, Error>) in
            switch result {
            case .success(let response):
                guard response.success == true, let userData = response.data else {
                    showToast(message: response.message ?? String(with: .somethingWentWrong))
                    return
                }
                userData.saveUserInfo(data: userData)
                userSingleton.write(type: .isTrusteeMode, value: false)
                userSingleton.write(type: .isUserLogin, value: true)
                let vc = TabbarVC.instantiate(.Dashboard)
                self.transitionToRootVC(vc)
            case .failure(let error):
                debugPrint(error)
                showToast(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - SOCIAL LOGIN
extension AuthViewModel{
    func loginWithSocialMedia(socialMedia: SocialMedia) {
        switch socialMedia {
        case .apple:
            loginWithApple()
        case .google:
            loginWithGoogle()
        case .facebook: break
        }
    }
    
    func loginWithGoogle() {
        guard let presentingViewController = view else { return }
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { signInResult, error in
            guard let user = signInResult?.user, error == nil else { return }
            self.storeSocialInfo = SocialInfo(
                firstName: user.profile?.givenName ?? "",
                lastName: user.profile?.familyName,
                email: user.profile?.email,
                socialID: user.userID,
                type: "2"
            )
            self.socialLoginAPIConsume()
        }
    }
    
    func socialLoginAPIConsume() {
        let params: Parameters
        params = [
            ParameterKeyNames.Auth.full_name : "\(self.storeSocialInfo?.firstName ?? "") \(self.storeSocialInfo?.lastName ?? "")",
            ParameterKeyNames.Auth.email: self.storeSocialInfo?.email ?? "",
            ParameterKeyNames.Auth.socialType: self.storeSocialInfo?.type ?? "",
            ParameterKeyNames.Auth.socialID: self.storeSocialInfo?.socialID ?? "",
        ]
        
        serviceManager.requestAPI(apiEndPoint: .socialLogin, parameters: params) { (result: Result<UserModel, Error>) in
            switch result {
            case .success(let response):
                guard response.success == true, let userData = response.data else {
                    showToast(message: response.message ?? String(with: .somethingWentWrong))
                    return
                }
                userData.saveUserInfo(data: userData)
                userSingleton.write(type: .isTrusteeMode, value: false)
                userSingleton.write(type: .isSocialLogin, value: true)
                userSingleton.write(type: .isUserLogin, value: true)
                let vc = TabbarVC.instantiate(.Dashboard)
                self.transitionToRootVC(vc)
            case .failure(let error):
                debugPrint(error)
                showToast(message: error.localizedDescription)
            }
        }
    }
}

// MARK: - Apple Login
extension AuthViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func loginWithApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view?.view.window ?? ASPresentationAnchor()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        var firstName = appleIDCredential.fullName?.givenName ?? ""
        var lastName = appleIDCredential.fullName?.familyName ?? ""
        var email = appleIDCredential.email ?? "\(appleIDCredential.user)@apple.com"
        let appleId = appleIDCredential.user
        
        if firstName.isEmpty || lastName.isEmpty {
            firstName = KeychainItem.firstName
            lastName = KeychainItem.lastName
            email = KeychainItem.currentEmail
        }
        saveUserInKeychain(userIdentifier: appleId, email: email, firstName: firstName, lastName: lastName)
        self.storeSocialInfo = SocialInfo(firstName: firstName, lastName: lastName, email: email, socialID: appleId, type: "3")
        self.socialLoginAPIConsume()
    }
    
    private func saveUserInKeychain(userIdentifier: String, email: String, firstName: String, lastName: String) {
        let keychainItems: [(account: String, value: String)] = [
            ("userIdentifier", userIdentifier),
            ("email", email),
            ("firstName", firstName),
            ("lastName", lastName)
        ]
        
        for item in keychainItems {
            do {
                try KeychainItem(service: bundleID, account: item.account).saveItem(item.value)
            } catch {
                print("Unable to save \(item.account) to keychain: \(error)")
            }
        }
    }
}
