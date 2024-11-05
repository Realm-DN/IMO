//
//  UIView+Extensions.swift
//

import UIKit
import Foundation

let filteredMapIconList = ["FAMILY & RELATIVES", "CLOSE FRIENDS", "WORK FRIENDS", "UNI FRIENDS", "CLUB FRIENDS", "TRAVEL FRIENDS", "NEIGHBORS", "COLLEAGUES", "OLD FRIENDS", "GAMING FRIENDS", "SPORTS TEAM", "VOLUNTEERS", "MENTORS", "CLIENTS", "CUSTOMERS","FAMILY & RELATIVES", "CLOSE FRIENDS", "WORK FRIENDS", "UNI FRIENDS", "CLUB FRIENDS", "TRAVEL FRIENDS", "NEIGHBORS", "COLLEAGUES", "OLD FRIENDS", "GAMING FRIENDS", "SPORTS TEAM", "VOLUNTEERS", "MENTORS", "CLIENTS","FAMILY & RELATIVES", "CLOSE FRIENDS", "WORK FRIENDS", "UNI FRIENDS", "CLUB FRIENDS", "TRAVEL FRIENDS", "NEIGHBORS", "COLLEAGUES", "OLD FRIENDS", "GAMING FRIENDS", "SPORTS TEAM", "VOLUNTEERS", "MENTORS", "CLIENTS"]

extension UIView{
    func configureNavViewContainer() {
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 25
    }
}

extension UITraitCollection {
    var isLightMode: Bool {
        if #available(iOS 12.0, *) {
            return userInterfaceStyle == .light
        } else {
            return true
        }
    }
}

import UIKit

class OrientationManager {
    
    static let shared = OrientationManager()
    
    private var orientationChangeHandlers: [(UIInterfaceOrientation) -> Void] = []
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func addOrientationChangeHandler(_ handler: @escaping (UIInterfaceOrientation) -> Void) {
        orientationChangeHandlers.append(handler)
    }
    
    @objc private func handleOrientationChange() {
        let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        orientationChangeHandlers.forEach { $0(orientation ?? .unknown) }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
