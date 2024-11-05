//
//  RootNavigator.swift
//

import UIKit
import Foundation

let rootNavigator = RootNavigator.shared
class RootNavigator {
    static let shared = RootNavigator()
    
    func callHomeVC() {
        let viewController: UIViewController

        let isTrusteeMode = userSingleton.read(type: .isTrusteeMode) ?? false
        if isTrusteeMode{
            viewController = TabbarVC.instantiate(.Dashboard)
        }
        else{
            if UserSingleton.shared.getUserData()?.id != nil {
                viewController = TabbarVC.instantiate(.Dashboard)
            } else {
                viewController = StartVC.instantiate(.Auth)
            }
        }
        UIViewController().transitionToRootVC(viewController)
    }

    func callAuthVC() {
        UserSingleton.shared.write(type: .isUserLogin, value: false)
        UserSingleton.shared.clearAllDataOnLogout()
        let vc =  WelcomeVC.instantiate(.Auth)
        UIViewController().transitionToRootVC(vc)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

extension NSObject {
    func transitionToRootVC(_ viewController: UIViewController) {
        guard let window = keyWindow else {return}
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            let navigationController = UINavigationController(rootViewController: viewController)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }, completion: nil)
    }
}
