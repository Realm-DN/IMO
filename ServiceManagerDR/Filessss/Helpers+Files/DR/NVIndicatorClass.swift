//
//  NVIndicatorClass.swift
//

import Foundation
import NVActivityIndicatorView
import UIKit

extension NSObject {
    @objc  func startIndicator() {
        DispatchQueue.main.async {
            let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
            activityIndicatorView.type = .circleStrokeSpin
            activityIndicatorView.color = UIColor.blue
            activityIndicatorView.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            activityIndicatorView.startAnimating()
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            
            let overlayView = UIView(frame: window.bounds)
            overlayView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.4)
            
            
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.alpha = 0.8
            blurEffectView.frame = window.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlayView.addSubview(blurEffectView)
            
            overlayView.addSubview(activityIndicatorView)
            window.addSubview(overlayView)
        }
    }
    
    @objc func stopIndicator() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            
            if let overlayView = window.subviews.first(where: { $0.backgroundColor == UIColor.systemBackground.withAlphaComponent(0.4) }) {
                overlayView.removeFromSuperview()
            }
        }
    }
}


//MARK: - ErrorMessages
struct ErrorMessages {
    static let internetMessage = "Please check your internet connection and try again."
    static let somethingWentWrong = "Something went wrong. Please try again later."
    static let session = "Session Expired"
    static let infoNotFound = "Information not found."
}
