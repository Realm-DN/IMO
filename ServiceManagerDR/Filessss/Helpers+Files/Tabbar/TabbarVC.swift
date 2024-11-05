//
//  TabbarVC.swift
//

import UIKit

class TabbarVC: UITabBarController {
    let viewModel = TabViewModel()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupTabBarAppearance()
            self.delegate = self
            instantiateVCs()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.navigationBar.isHidden = true
        }
    
    private func setupTabBarAppearance() {
            if #available(iOS 15.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                tabBar.scrollEdgeAppearance = appearance
                tabBar.standardAppearance = appearance
            }
            tabBar.barTintColor = .white
            tabBar.tintColor = .systemBlue
            tabBar.unselectedItemTintColor = .gray
            tabBar.layer.applyShadow(color: .black, offset: .zero, radius: 10, opacity: 0.2)
        }
    
    private func instantiateVCs() {
            let userType: TabViewModel.UserType = determineUserType()
            self.viewControllers = viewModel.getViewControllers(userType: userType)
            self.selectedIndex = 0
            viewModel.configureTabBar(tabBar)
        }
        
        private func determineUserType() -> TabViewModel.UserType {
            let isGuest = isGuestMode()
            return isGuest ? .trusteeUser : .mainUser
        }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            updateTabBarFrame()
        }
    
    private func updateTabBarFrame() {
            var tabFrame = tabBar.frame
            tabFrame.size.height = 80
            tabFrame.origin.y = view.frame.height - 80
            tabBar.frame = tabFrame
            tabBar.layer.applyRoundedCorners([.topLeft, .topRight], radius: 25)
        }
}

class TabViewModel {
    enum UserType {
            case mainUser
            case trusteeUser
        }
    
    func getViewControllers(userType: UserType) -> [UIViewController] {
        let homeVC: UIViewController = HomeVCNew.instantiate(.Dashboard)
        let notificationVC: UIViewController = NotificationsVC.instantiate(.Dashboard)
        let settingsVC: UIViewController = SettingVC.instantiate(.Dashboard)
        let trusteeVC: UIViewController = TrusteeUserVC.instantiate(.Dashboard)

        let controllers: [UIViewController]
        let imageNames: [String]
        let selectedImageNames: [String]
        
        switch userType {
        case .mainUser:
            controllers = [homeVC, notificationVC, settingsVC]
            imageNames = ["home", "notification", "setting_"]
            selectedImageNames = ["home_select", "notification_select_dot", "setting_select"]
        case .trusteeUser:
            controllers = [trusteeVC, settingsVC]
            imageNames = ["home", "setting_"]
            selectedImageNames = ["home_select", "setting_select"]
        }
        
        // Configure the tab bar items for the controllers
        for ((vc, imageName), selectedImageName) in zip(zip(controllers, imageNames), selectedImageNames) {
            configureTabBarItem(for: vc, imageName: imageName, selectedImageName: selectedImageName)
        }
        
        return controllers.map { UINavigationController(rootViewController: $0) }
    }

        
        private func configureTabBarItem(for viewController: UIViewController, imageName: String, selectedImageName: String) {
            viewController.tabBarItem.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
            viewController.tabBarItem.selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal)
        }
        
        func configureTabBar(_ tabBar: UITabBar) {
            tabBar.items?.forEach { item in
                item.title = ""
                item.image = item.image?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 10)
                item.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0)
            }
        }
    }

// MARK: - Extensions

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage {
        let ratio = min(targetSize.width / size.width, targetSize.height / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}

extension CALayer {
    func applyRoundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.mask = mask
    }
}

// MARK: - TabBar Delegate

extension TabbarVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
            print("Selected index: \(index)")
        }
        return true
    }
}
