//
//  UITextView+Extensions.swift
// 

import UIKit
import Foundation

extension UITextView {
    func centerContentVertically() {
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let heightOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(0, heightOffset)
        contentOffset.y = -positiveTopOffset
    }
    func setPadding(left: CGFloat, right: CGFloat,top:CGFloat) {
        textContainerInset = UIEdgeInsets(top: top, left: left, bottom: 0, right: right)
    }
}
