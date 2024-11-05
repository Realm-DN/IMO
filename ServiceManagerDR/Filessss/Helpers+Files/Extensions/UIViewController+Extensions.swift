//
//  UIViewController+Extensions.swift
//

import UIKit
import Foundation

extension UIViewController {
    func configureNavBarAuth(_ title: String = "") {
        self.title = title
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationController?.view.tintColor = UIColor.white
        
//        let backButton = UIBarButtonItem()
//        let font = UIFont.boldSystemFont(ofSize: 20)
//        backButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
//        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // Custom back button appearance
            let backButton = UIBarButtonItem()
            let font = UIFont.boldSystemFont(ofSize: 20)
            backButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

            // Set custom back button image
            let backImage = UIImage(named: "ic_back")
            self.navigationController?.navigationBar.backIndicatorImage = backImage
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
    }
    func configureNavBarIN(_ title: String = "") {
        self.title = title
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.view.backgroundColor = UIColor.white
        self.navigationController?.view.tintColor = UIColor.black
        
//        let backButton = UIBarButtonItem()
//        let font = UIFont.boldSystemFont(ofSize: 20)
//        backButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
//        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        // Custom back button appearance
            let backButton = UIBarButtonItem()
            let font = UIFont.boldSystemFont(ofSize: 20)
            backButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

            // Set custom back button image
            let backImage = UIImage(named: "ic_back")
            self.navigationController?.navigationBar.backIndicatorImage = backImage
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
    }
}

extension CALayer {
    func applyShadow(color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        shadowColor = color.cgColor
        shadowOffset = offset
        shadowRadius = radius
        shadowOpacity = opacity
        masksToBounds = false
    }
}

extension NSObject{
    func isGuestMode() -> Bool {
        return userSingleton.read(type: .isTrusteeMode) ?? false
    }
    
    func handleGuestModeAction() -> Bool {
        if isGuestMode() {
            showPopupforGuestMode()
            return true
        }
        return false
    }
    
    func showPopupforGuestMode(){
        showCustomAlert(title: "", message: String(with: .loginSignupToUseFeature), okTitle: String(with: .title_Continue), cancelTitle: String(with: .alertCancel)) { okPressed, isCancel in
            if okPressed{
                UserSingleton.shared.write(type: .isTrusteeMode, value: false)
                rootNavigator.callAuthVC()
            }
        }
    }
}


extension UIViewController{
    func convertStringToDate(_ dateString: String, dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Use a POSIX locale to avoid unexpected issues
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: dateString)
    }
    
    // Function to get time ago format
    func timeAgoSinceDate(_ date: Date, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = now < date ? now : date
        let latest = (earliest == now) ? date : now
        let components: DateComponents = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year, .second], from: earliest, to: latest)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1) {
            return numericDates ? "1 year ago" : "Last year"
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1) {
            return numericDates ? "1 month ago" : "Last month"
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1) {
            return numericDates ? "1 week ago" : "Last week"
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1) {
            return numericDates ? "1 day ago" : "Yesterday"
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1) {
            return numericDates ? "1 hour ago" : "An hour ago"
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1) {
            return numericDates ? "1 minute ago" : "A minute ago"
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
    }
    
    func setupBackButton(_ title: String? = "",navTitle:String? = "") {
        self.navigationController?.view.backgroundColor = .darkBlue7D95BA //UIColor("038198")
        self.navigationController?.view.tintColor =  .darkBlue7D95BA //UIColor("038198")
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        let backButton = UIBarButtonItem()
        backButton.title = title
        let font =  UIFont(name: "Helvetica-Regular", size: 16) ??  UIFont.systemFont(ofSize: 16, weight: .regular)
        backButton.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.navigationItem.title = navTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.font1(size: .size18_28),NSAttributedString.Key.foregroundColor:  UIColor.darkBlue7D95BA ?? UIColor("7D95BA")] //UIColor("038198")]
    }
}


//extension UIViewController {
//    func configureRefreshControl(for scrollView: UIScrollView, action: Selector) -> UIRefreshControl {
//        let refreshControl = UIRefreshControl()
//        refreshControl.tintColor = appColor
//        refreshControl.addTarget(self, action: action, for: .valueChanged)
//        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        scrollView.refreshControl = refreshControl
//        return refreshControl
//    }
//}

extension NSObject{
    func configureRefreshControl(for scrollView: UIScrollView, action: Selector) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = appColor
        refreshControl.addTarget(self, action: action, for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        scrollView.refreshControl = refreshControl
        return refreshControl
    }
}
