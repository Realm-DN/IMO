//
//  LangSettings.swift
// 

import Foundation
import UIKit

class SaveUserResponse : NSObject {
    static let shared = SaveUserResponse()
    
    func saveLanguage(_ lang: String) {
        UserDefaults.standard.set(lang, forKey: "Locale")
        UserDefaults.standard.synchronize()
    }
    
    func currentLanguage() -> String {
        return UserDefaults.standard.string(forKey: "Locale") ?? "en"
    }
    
    func getLanguage() -> String  {
        return UserDefaults.standard.string(forKey: "Locale") ?? "en"
    }
}
extension String {
    var appLocalized: String {
        let lang = SaveUserResponse.shared.currentLanguage()
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
//    func localized() -> String {
//        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
//    }
    func localized() -> String {
        let bundle = Bundle.localizedBundle() ?? Bundle.main
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    
    func localizeWithFormat(arguments: CVarArg...) -> String{
        return String(format: self.localized(), arguments: arguments)
    }
}

extension Bundle {
    
    private static var bundle: Bundle!
    
//    public static func localizedBundle() -> Bundle! {
//        if bundle == nil {
//            let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
//            if let path = Bundle.main.path(forResource: appLang, ofType: "lproj") {
//                bundle = Bundle(path: path)
//            } else {
//                // Handle the case where the resource file is not found
//                print("Resource file for language \(appLang) not found")
//                // Fallback to a default language or handle it according to your app logic
//                let defaultLangPath = Bundle.main.path(forResource: "en", ofType: "lproj")
//                bundle = Bundle(path: defaultLangPath!)
//            }
//        }
//        return bundle
//    }
    
    public static func localizedBundle() -> Bundle? {
        if bundle == nil {
            let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
            
            // Attempt to find the path for the requested language
            if let path = Bundle.main.path(forResource: appLang, ofType: "lproj") {
                bundle = Bundle(path: path)
            } else {
                // Handle the case where the resource file for the requested language is not found
                print("Resource file for language \(appLang) not found")
                
                // Provide a default language fallback safely
                if let defaultLangPath = Bundle.main.path(forResource: "en", ofType: "lproj") {
                    bundle = Bundle(path: defaultLangPath)
                } else {
                    // Handle the case where the default language resource file is also not found
                    print("Default resource file for language 'en' not found")
                    bundle = Bundle.main // Fallback to the main bundle
                }
            }
        }
        return bundle
    }

    
//    public static func setLanguage(lang: String) {
//        UserDefaults.standard.set(lang, forKey: "app_lang")
//        let path: String?
//        if lang == "fr" {
//            path = Bundle.main.path(forResource: "fr", ofType: "lproj")
//        } else {
//            path = Bundle.main.path(forResource: lang, ofType: "lproj")
//        }
//        if let path = path {
//            bundle = Bundle(path: path)
//        } else {
//            print("Resource file for language \(lang) not found")
//            let defaultLangPath = Bundle.main.path(forResource: "en", ofType: "lproj")
//            bundle = Bundle(path: defaultLangPath!)
//        }
//    }
    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "app_lang")

        // Determine the path for the requested language
        let path: String?
        if lang == "fr" {
            path = Bundle.main.path(forResource: "fr", ofType: "lproj")
        } else {
            path = Bundle.main.path(forResource: lang, ofType: "lproj")
        }

        // Set the bundle to the path if it exists
        if let path = path {
            bundle = Bundle(path: path)
        } else {
            // Handle the case where the requested language resource file is not found
            print("Resource file for language \(lang) not found")
            
            // Fallback to the default language (English) and ensure defaultLangPath is safely unwrapped
            if let defaultLangPath = Bundle.main.path(forResource: "en", ofType: "lproj") {
                bundle = Bundle(path: defaultLangPath)
            } else {
                // Handle the case where the default language resource file is also not found
                print("Default resource file for language 'en' not found")
                bundle = Bundle.main // Fallback to the main bundle
            }
        }
    }

}

