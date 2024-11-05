//
//  Constant.swift
//


import Foundation
import UIKit


//MARK: - Images
struct CommonImagesName{
    static let userPlaceHolder = "userProfile"
    
    static let imagEyeFill = "eyeFill"
    static let imageEyeEmpty = "eyeEmpty"
}


//MARK: - DeviceType
enum DeviceType{
    static let iOS = "I"
    static let android = "A"
}

struct UserDefaultKey {
    static var NotificationON = "NotificationON"
}

let kImageUploadLimit = 10

extension Bundle {
    static var appVersionShort: String {
        return main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "⚠️"
    }
    
    static var appVersionLong: String {
        return "Version " + (main.infoDictionary?["CFBundleVersion"] as? String ?? "⚠️")
    }
    
    static var appName: String {
        return main.infoDictionary?["CFBundleName"] as? String ?? "⚠️"
    }
    
    static var appVersionFull: String {
        if let shortVersion = main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = main.infoDictionary?["CFBundleVersion"] as? String {
            return "Version \(shortVersion)(\(buildNumber))"
        } else {
            return "Version ⚠️"
        }
    }
}


//MARK: - AppDetails
struct AppDetails {
    static let appBundleId = Bundle.main.bundleIdentifier ?? ""
    static let copyrightText = ( userSingleton.getAppSettingsData()?.copyright ?? "© 2024 \(Bundle.appName)." + " " + "All Rights Reserved")
    
    static let deviceToken : String? = userSingleton.read(type: .deviceToken)
    static let deviceUUID : String? =  UIDevice.current.identifierForVendor?.uuidString//UserSingleton.shared.read(type: .deviceUUID)
    static let fcmToken : String? = userSingleton.read(type: .fcmToken)
    static let currentTimeZone =  TimeZone.current.identifier
    static let accept_Language : String? = UserDefaults.standard.string(forKey: "app_lang")
    static let device_Type =  DeviceType.iOS
    static let app_Version = Bundle.appVersionShort
    static let authorization = "Bearer \(fcmToken ?? "")"
    static let deviceName = UIDevice.current.name
    //"" //kBasicSetting?.copyright ?? ""
}

struct AlertMessages{
    static let somethingWentWrong = "Something went wrong!"
    static let noMessageFound = "Your chat list is currently empty.\nThere are no ongoing conversations or messages to display at this time."
    static let noNotificationFound = "Your notification list is currently empty.\nThere are no new notifications to display at this time."
    static let noBlockUserFound = "Your blocked user list is currently empty.\nYou have not blocked any users at this time."
    static let noEventFound = "Your event invitation list is currently empty\nThere are no pending event invitations to display at this time."
    static let noCommentFound = "Be the first to make a comment! The comment list is currently empty."
    
}

var kAppStoreID = ""

func isValidEmail(email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

func isValidPhoneNumber(phoneNumber: String) -> Bool {
    let phoneRegex = "^\\(\\d{3}\\) \\d{3}-\\d+$"
    let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    return phonePredicate.evaluate(with: phoneNumber)
}
func cleanPhoneNumber(_ phoneNumber: String) -> String {
    let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "")
        .replacingOccurrences(of: ")", with: "")
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "-", with: "")
    return cleanedPhoneNumber
}

func isValidPassword(password:String) -> Bool {
    let regex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
    let isMatched = NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: password)
    if isMatched {
        return true
    }
    return false
}

func isEmpty(item:String?)->Bool{
    
    if  item == "<null>" || item == nil || item == "Null" || item == "NULL" || (item?.isEmpty == true) ||  (item == "") {
        return true
    }
    return false
}

func passwordSame(password:String,confirmPassword:String) -> Bool {
    if password == confirmPassword {
        return true
    }
    return false
}


//post_install do |installer|
//  installer.generated_projects.each do |project|
//    project.targets.each do |target|
//      target.build_configurations.each do |config|
//        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
//        xcconfig_path = config.base_configuration_reference.real_path
//        xcconfig = File.read(xcconfig_path)
//        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
//        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
//      end
//    end
//  end
//end
