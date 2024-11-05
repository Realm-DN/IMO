//
//  ProfileViewModel.swift
//

import Foundation
import UIKit

class ProfileViewModel{
    
    var view : ProfileVC?
    
    var id: String?
    var imageData: Data?
    var imageNameS3 : String?
    var selectedDate =  ""
    var slectedHandicapValue = ""
    
    func getProfile(completion:@escaping GeneralCompletion){
        serviceManager.requestAPI(apiEndPoint: .getProfile(userId: "")) { (result:Result<UserModel,Error>) in
            switch result{
            case .success(let response):
                if response.success == true{
                    guard let userData = response.data else {return}
                    userData.saveUserInfo(data: userData)
                    completion(true,response.message ?? "")
                }else{
                    showToast(message: response.message ?? "")
                    completion(false,response.message ?? "")
                }
            case .failure(let error):
                showToast(message: error.localizedDescription)
            }
        }
    }
    
    func isValid() -> Bool {
        guard let username = self.view?.tfFullName.text, !username.isEmpty else {
            showToast(message: String(with: .alertEnterName))
            return false
        }
        return true
    }
    
    func updateProfile(image:String,completion:@escaping GeneralCompletion){
        if isValid(){
            var params: [String: Any] = [
                ParameterKeyNames.Auth.full_name: self.view?.tfFullName.text ?? "",
                ParameterKeyNames.Auth.userName: self.view?.tfUserName.text ?? "",
                ParameterKeyNames.Auth.email: self.view?.tfEmail.text ?? ""
            ]
            if image.isEmpty == false{
                params[ParameterKeyNames.Auth.image] = image
            }
            serviceManager.requestAPI(apiEndPoint: .updateProfile,parameters: params) { (result:Result<UserModel,Error>) in
                switch result{
                case .success(let response):
                    if response.success == true{
                        guard let userData = response.data else {return}
                        userData.saveUserInfo(data: userData)
                        showToast(message: response.message ?? "")
                        completion(true,response.message ?? "")
                    }else{
                        showToast(message: response.message ?? "")
                        completion(false,response.message ?? "")
                    }
                case .failure(let error):
                    showToast(message: error.localizedDescription)
                }
            }
        }
    }
}
