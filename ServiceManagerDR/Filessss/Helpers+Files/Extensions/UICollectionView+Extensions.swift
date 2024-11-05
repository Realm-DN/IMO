//
//  UICollectionView+Extensions.swift
//
import UIKit

//MARK: - UICollectionView Extension function
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension Set {
    func element(at index: Int) -> Element? {
        let array = Array(self)
        return array[safe: index]
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}

import UIKit

extension UICollectionView {
    func animateJumpOnCellTap() {
        // Create a scale animation
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 0.1
        scaleAnimation.autoreverses = true
        
        // Create a position animation
        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.fromValue = CGPoint(x: self.center.x, y: self.center.y)
        positionAnimation.toValue = CGPoint(x: self.center.x, y: self.center.y - 10)
        positionAnimation.duration = 0.1
        positionAnimation.autoreverses = true
        
        // Create a group animation
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [scaleAnimation, positionAnimation]
        groupAnimation.duration = 0.1
        
        self.layer.add(groupAnimation, forKey: "jumpAnimation")
    }
}
