//
//  RootNavigator.swift
//

import UIKit
import Foundation


class RootNavigator {
    static let shared = RootNavigator()
    
    func callHomeVC() {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
//            return
//        }
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            var vc: UIViewController
//
//            if UserSingleton.shared.getCurrentUserProfileData()?.id != nil {
//                vc = TabbarVC.instantiate(.Dashboard)
//            } else {
//                vc = WelcomeScreen.instantiate(fromStoryboard: .Auth)
//            }
//
//            DispatchQueue.main.async {
//                if UserSingleton.shared.getCurrentUserProfileData()?.id != nil {
//                    sceneDelegate.window?.rootViewController = vc
//                } else {
//                    sceneDelegate.navigationController = UINavigationController(rootViewController: vc)
//                    sceneDelegate.window?.rootViewController = sceneDelegate.navigationController
//                }
//                sceneDelegate.window?.makeKeyAndVisible()
//            }
//        }
    }
    
    func callHomeVC1() {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
//            return
//        }
//        var vc = UIViewController()
//        if UserSingleton.shared.getCurrentUserProfileData()?.id != nil{
//            vc = TabbarVC.instantiate(fromStoryboard: .Dashboard)
//             sceneDelegate.window?.rootViewController = vc
//             sceneDelegate.window?.makeKeyAndVisible()
//        }
//        else {
//            vc = WelcomeScreen.instantiate(fromStoryboard: .Auth)
//            sceneDelegate.navigationController = UINavigationController(rootViewController: vc)
//            sceneDelegate.window?.rootViewController = sceneDelegate.navigationController
//            sceneDelegate.window?.makeKeyAndVisible()
//            
//        }
    }
    
    func callHomeVC3() {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
//            return
//        }
//        var vc = UIViewController()
//        if UserSingleton.shared.getCurrentUserProfileData()?.id != nil{
//            vc = TabbarVC.instantiate(fromStoryboard: .Dashboard)
//             sceneDelegate.window?.rootViewController = vc
//             sceneDelegate.window?.makeKeyAndVisible()
//        }
//        else {
//            vc = LoginVC.instantiate(fromStoryboard: .Auth)
//            sceneDelegate.navigationController = UINavigationController(rootViewController: vc)
//            sceneDelegate.window?.rootViewController = sceneDelegate.navigationController
//            sceneDelegate.window?.makeKeyAndVisible()
//        }
    }
}
