//
//  ServiceManagerDRHelper.swift
// 

import Foundation
import UIKit
import Network

// Singleton instance of ServiceManagerDR
let networkService = ServiceManagerDR.shared
typealias paramKey = ParametersKeys
typealias HTTPHeaders = [paramKey: String]
typealias Parameters = [paramKey: Any]
typealias ResultCompletion<T> = (Result<T, NetworkError>) -> Void

// Enum representing HTTP methods
public enum HTTPMethod: String, Sendable {
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case query = "QUERY"
    case trace = "TRACE"
}

// Base URL Configuration
let isLiveURL = true
var kbaseURL: String {
    return isLiveURL ? "https://pro.smilingfacesworldwide.com/api/" : "http://192.168.1.200:8163/api/"
}

// Helper class for displaying alerts
class AlertHelper: NSObject {
    static func showAlert(title: String, message: String, actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)]) {
        guard let topViewController = getTopViewController() else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        topViewController.present(alert, animated: true, completion: nil)
    }
}

// Helper method to get the top view controller
public func getTopViewController() -> UIViewController? {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        return windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController?.topMostViewController()
    }
    return nil
}

// Extension to find the top most view controller
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? navigationController
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? tabBarController
        }
        return self
    }
}

// Enum for API Endpoints
enum APIEndpoint {
    // Auth Endpoints
    case login, signup, socialLogin, changePassword, forgotPassword, logout
    case updateProfile, getProfile(userId: String), appSettings, deleteAccount
    
    // Rating Endpoints
    case rating, ratingList(page: String), deleteRating, s3Upload
    
    case get_prices
}

// Extension to provide path and HTTP method for each API endpoint
extension APIEndpoint {
    var path: String {
        switch self {
        case .login: return "login"
        case .signup: return "signup"
        case .socialLogin: return "social-login"
        case .changePassword: return "change-password"
        case .forgotPassword: return "forgot-password"
        case .logout: return "logout"
        case .updateProfile: return "update-profile"
        case .getProfile(let userId): return "get-profile" + (userId.isEmpty ? "" : "?user_id=\(userId)")
        case .appSettings: return "app-settings"
        case .deleteAccount: return "delete-account"
        case .rating: return "rating"
        case .ratingList(let page): return "rating-list" + (page.isEmpty ? "" : "?page=\(page)")
        case .deleteRating: return "delete-rating"
        case .s3Upload: return "s3-upload"
        case .get_prices: return "get-prices"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .signup, .socialLogin, .changePassword, .forgotPassword, .updateProfile, .deleteAccount, .s3Upload, .rating, .deleteRating, .ratingList:
            return .post
        case .getProfile, .appSettings, .logout:
            return .get
        case .get_prices: return .post
        }
    }
}

// Enum representing network errors
enum NetworkError: Error {
    case noInternetConnection
    case invalidURL
    case unknownError
    case networkError(Error)
    case parsingError(Error)
    case serverError(Int, String)
    case unauthorized
    case paymentRequired
}

// Enum representing upload types
enum UploadTypeDR {
    case fetchData
    case files(FileModelDR)
}

// Function to check internet connectivity
var isConnectedToInternet: Bool {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")
    var isConnected = false
    monitor.pathUpdateHandler = { path in
        isConnected = path.status == .satisfied
    }
    monitor.start(queue: queue)
    return isConnected
}

// MARK: - Helper Methods
// Function to generate headers for network requests
func generateHeadersDR() -> HTTPHeaders {
    var headers: HTTPHeaders = [
        .accept: "application/json",
        .acceptLanguage: UserDefaults.standard.string(forKey: "app_lang") ?? "",
        .deviceToken: UIDevice.current.identifierForVendor?.uuidString ?? "",
        .timezone: TimeZone.current.identifier,
        .deviceName: "\(UIDevice.current.name) \(UIDevice.current.systemVersion)",
        .fcmToken: userSingleton.read(type: .fcmToken) ?? "",
        .deviceType: "I",
        .appVersion: appVersionFull
    ]
    
    let authorization: String? = userSingleton.read(type: .authorization)
    let isAuthorized = (authorization != nil && !authorization!.isEmpty)
    if isAuthorized, let token = authorization {
        headers[.authorization] = "Bearer \(token)"
    }
    return headers
}

// Function to get the full app version
var appVersionFull: String {
    let infoDictionary = Bundle.main.infoDictionary
    let shortVersion = infoDictionary?["CFBundleShortVersionString"] as? String ?? "⚠️"
    let buildNumber = infoDictionary?["CFBundleVersion"] as? String ?? ""
    return "Version \(shortVersion)(\(buildNumber))"
}

// Enum representing parameter keys
public enum ParametersKeys: String {
    case accept = "Accept"
    case acceptLanguage = "Accept-Language"
    case deviceToken = "Device-Token"
    case timezone = "Timezone"
    case deviceName = "Device-Name"
    case fcmToken = "FCM-Token"
    case deviceType = "Device-Type"
    case appVersion = "App-Version"
    case authorization = "Authorization"
    case page = "page"
}
