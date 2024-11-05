//
//  ActionSheet+Extensions.swift
//

import UIKit
import Foundation

extension UIViewController {
    func showAlert(title: String, message: String, buttons: [(String, UIAlertAction.Style, UIImage?, () -> Void)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for (buttonTitle, style, image, action) in buttons {
            let customAction = UIAlertAction(title: buttonTitle, style: style) { _ in
                action()
            }
            
            if let image = image {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
                imageView.image = image.withRenderingMode(.alwaysOriginal) // Set rendering mode to alwaysOriginal to remove tint
                customAction.setValue(imageView.image, forKey: "image")
            }
            
            alert.addAction(customAction)
        }
        
        alert.addAction(UIAlertAction(title: String(with: .alertCancel), style: .cancel) { _ in
            print("User clicked Dismiss button")
        })
        
        self.present(alert, animated: true, completion: {
            print("Completion block")
        })
    }
}
