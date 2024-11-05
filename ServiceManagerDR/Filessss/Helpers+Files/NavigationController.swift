//
//  NavigationController.swift
//

import Foundation
import UIKit

enum StoryboardName: String {
    case LaunchScreen, Main
    
    
    var instance: UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: .main)
    }
    
    func viewController<T: UIViewController>() -> T {
        let storyboardID = String(describing: T.self)
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("Unable to instantiate view controller with identifier '\(storyboardID)' from storyboard '\(self.rawValue)'.")
        }
        return scene
    }
}

extension UIViewController {
    static func instantiate(_ storyboard: StoryboardName) -> Self {
        return storyboard.viewController()
    }
}

extension UIViewController{
    func pushWebViewVC(_ urlType: WebUrl) {
        let webVC = WebVC()
        webVC.urlType = urlType
        pushViewController(vc: webVC)
    }
    
    func pushViewController(vc: UIViewController) {
        vc.modalPresentationStyle = .fullScreen
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//extension UIViewController {
//    func performSegueToReturnBack()  {
//        if let nav = self.navigationController {
//            if isRoot ?? false {
//                nav.popToRootViewController(animated: true)
//            }else{
//                nav.popViewController(animated: true)
//            }
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
//}

extension UIViewController {
    func returnBack() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}


import UIKit

extension UIBarButtonItem {
    private struct AssociatedObject {
        static var key = "action_closure_key"
    }
    
    var actionClosure: (()->Void)? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObject.key) as? ()->Void
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObject.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            target = self
            action = #selector(didTapButton(sender:))
        }
    }
    
    @objc func didTapButton(sender: Any) {
        actionClosure?()
    }
}
