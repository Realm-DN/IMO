//
//  UIApplication+Extensions.swift
//

import UIKit
import Foundation

extension UIApplication {
    var keyWindow: UIWindow? {
        guard let windowScene = connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first
    }
}

var keyWindow: UIWindow? {
    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
}

func getTopViewController(_ base: UIViewController? = nil) -> UIViewController? {
    let baseViewController = base ?? UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first(where: { $0.isKeyWindow })?.rootViewController
    
    if let nav = baseViewController as? UINavigationController {
        return getTopViewController(nav.visibleViewController)
    }
    
    if let tab = baseViewController as? UITabBarController, let selected = tab.selectedViewController {
        return getTopViewController(selected)
    }
    
    if let presented = baseViewController?.presentedViewController {
        return getTopViewController(presented)
    }
    
    return baseViewController
}
