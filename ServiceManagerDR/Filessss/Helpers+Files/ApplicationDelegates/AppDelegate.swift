//
//  AppDelegate.swift
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    //Variables
    var restrictRotation: UIInterfaceOrientationMask = .all
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sleep(2)
        setupAppearance()
        configureFirebase()
        configureGoogleServices()
        configureKeyboardManager()
        requestNotificationAuthorization()
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        UserSingleton.shared.write(type: .fcmToken, value: fcmToken ?? "")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.list, .banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Notification received: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    private func setupAppearance() {
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.setBackgroundImage(UIImage(), for: .default)
    }
    
    private func configureFirebase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    private func configureGoogleServices() {
        let apiKey = Google.kGooglePlaceKey
        GMSPlacesClient.provideAPIKey(apiKey)
        GMSServices.provideAPIKey(apiKey)
    }
    
    private func configureKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    private func requestNotificationAuthorization() {
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

struct Google {
    static let kGooglePlaceKey = "AIzaSyBu-nxV4WZzMmm7lWnhut3_vrv1wHf6srI"
    static let kGoogleClientKey = "AIzaSyBu-nxV4WZzMmm7lWnhut3_vrv1wHf6srI"
    static let kGoogleClientId = "126478892544-o1cjjq42467p4op9o71jqm6d65g4huj3.apps.googleusercontent.com"
}
