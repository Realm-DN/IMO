//
//  UserSingleton.swift
//

import Foundation

let userSingleton = UserSingleton.shared

enum SingletonType: String, CaseIterable {
    case fcmToken, userEmail, userPassword, isRememberMe, deviceToken, deviceUUID, user_name, isPush
    case isUserLogin, authorization, isSocialLogin, userData, userName, appSettings
    case subscriptionType, daysLeft, planStatus, planName, payment_from, hrs_left, minute_left, isfreeTrial, expiry_date
}

final class UserSingleton {
    static let shared = UserSingleton()
    private let userDefault = UserDefaults.standard
    private let permissionGrantKey = "permissionGrant"

    private init() {}

    var isUserGrantNotificationPermission: Bool? {
        get { userDefault.bool(forKey: permissionGrantKey) }
        set {
            newValue == nil ? userDefault.removeObject(forKey: permissionGrantKey) : userDefault.setValue(newValue, forKey: permissionGrantKey)
        }
    }

    private func getKey(for type: SingletonType) -> String { type.rawValue }

    func clearData(type: SingletonType) {
        userDefault.removeObject(forKey: getKey(for: type))
    }

    func write<T>(type: SingletonType, value: T?) {
        userDefault.set(value, forKey: getKey(for: type))
    }

    func read<T>(type: SingletonType) -> T? {
        userDefault.object(forKey: getKey(for: type)) as? T
    }

    func clearAllDataOnLogout() {
        SingletonType.allCases.forEach { type in
            if type != .fcmToken {
                userDefault.removeObject(forKey: getKey(for: type))
            }
        }
    }

    func clearUserDataOnly() {
        write(type: .isUserLogin, value: false)
        clearData(type: .userData)
    }

//    func saveUserData(_ modal: UserDataModel) {
//        saveData(modal, for: .userData)
//    }
//
//    func getUserData() -> UserDataModel? {
//        loadData(for: .userData)
//    }

//    func saveAppSettingsData(_ modal: AppSettingsModel) {
//        saveData(modal, for: .appSettings)
//    }
//
//    func getAppSettingsData() -> AppSettingsModel? {
//        loadData(for: .appSettings)
//    }

    private func saveData<T: Encodable>(_ data: T, for type: SingletonType) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            userDefault.set(encodedData, forKey: getKey(for: type))
        } catch {
            print("Error encoding data: \(error)")
        }
    }

    private func loadData<T: Decodable>(for type: SingletonType) -> T? {
        guard let storedData = userDefault.data(forKey: getKey(for: type)) else { return nil }
        do {
            return try JSONDecoder().decode(T.self, from: storedData)
        } catch {
            print("Error decoding data: \(error)")
            return nil
        }
    }
}

let auth =
"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI1IiwianRpIjoiNTQ0OTk1M2ZhMjMwYTI1NDMzNTYxOGYzMDI4NzQyNWUzNjFlOGU5ODY3ZDcwZTc1NTJlOGI5M2EwMTZhYmE1YmZiNDQ3MmYwNTc2NTdiNGQiLCJpYXQiOjE3MjIxNTMwODQuNzE3ODkxLCJuYmYiOjE3MjIxNTMwODQuNzE3ODkzLCJleHAiOjE3NTM2ODkwODQuNzE2NTQ2LCJzdWIiOiI3OSIsInNjb3BlcyI6W119.jAq0qMAAYuyUgq_I7aEpIC_Ly_NknqNDX6mHUZa6o-pVoUBuyoIqPouJaHJMGkFdwcNSKv4FS4xz76IIrY9lUAMxmk_CWvs-nCVbEMMl585vQfksIq-UJsMQgJW6Cow4eBxriXdD-C682v9e1W_KyVvq1tqeJWbFcOoQwYggGlt7DPRXLzsKiyZ6RrOgorjgvcPop2dwqK_O5djezWEhPsgN1kN9TWQ-xeTU-0nfdrdUP_kbgIYTq2A206mpeuk_6RRu3Dd-rySpgrWLG8J78lVMIKYhFd0Su0vlXqqagE0UNFuLE2G9UHfdodeyFWBlsYKtb05JeqNVUN2IbZxlc_yl24gzfiberf2dwBmk7AuOyAcH0kFNetqcIV5KFrDKXsYIgntAj-7mgPVS-WoeF-LYteMRlolaJecQ1Wk7roH1a1rsiBuKx8ratsf-km3XoOv2gBmHw39nbI84ClfjOWXY1Va3s5rGBeM9iMyeknI9Wi6OOVe7-6koZaghgrRrAJPeHeBeMV000U6vWVV1u9mrHPWmNxMSkoY-Re-PjcyRpPZYRtsaBn6MnVn2T7xRJMOgfcgK6JXMiTRKvPr_9bco9tq9fsG71tq-ml_VVyPlR9RZis_4IJyOPaYdosvatzIWKxCw00v203dxzieqTbbhRJda6dC-KOg-dziEpNI"
