//
//  UIButton+Extensions.swift
//

import UIKit
import Foundation
import Kingfisher

extension UIButton {
    enum CustomButtonType {
         case main
         case simple
         case simpleWithMediumText
         case simpleWithBorder
         case coloredBackGround
     }

    func designButton(buttonType: CustomButtonType = .main, offset: CGSize = CGSize(width: 0, height: 5), color: UIColor = .black, radius: CGFloat = 2.0, opacity: Float = 0.2) {
        switch buttonType {
        case .main:
            self.clipsToBounds = true
            self.layer.cornerRadius = self.frame.height / 2
            layer.masksToBounds = false
            layer.shadowOffset = offset
            layer.shadowColor = color.cgColor
            layer.shadowRadius = radius
            layer.shadowOpacity = opacity
            let backgroundCGColor = backgroundColor?.cgColor
            backgroundColor = nil
            layer.backgroundColor =  backgroundCGColor

        case .simple:
            self.clipsToBounds = true
            self.layer.borderWidth = 0
            self.backgroundColor = .clear
            self.titleLabel?.font = UIFont.systemFont(ofSize: self.titleLabel?.font.pointSize ?? 13, weight: .regular)
            self.setTitleColor(.darkGray, for: .normal)
        case .simpleWithMediumText:
            self.clipsToBounds = true
            self.layer.borderWidth = 0
            self.backgroundColor = .clear
            self.titleLabel?.font = UIFont.systemFont(ofSize: self.titleLabel?.font.pointSize ?? 13, weight: .semibold)
            self.setTitleColor(.darkGray, for: .normal)
            
        case .simpleWithBorder:
            self.clipsToBounds = true
            self.layer.cornerRadius = 5
            self.layer.borderWidth = 1
            self.layer.borderColor = AppColor.kAppColor?.cgColor
            self.backgroundColor = .clear
            self.titleLabel?.font = UIFont.systemFont(ofSize: self.titleLabel?.font.pointSize ?? 13, weight: .regular)
            self.setTitleColor(AppColor.kAppColor, for: .normal)

        case .coloredBackGround:
            self.clipsToBounds = true
            self.layer.cornerRadius = 5
            self.backgroundColor = AppColor.kAppColor
            self.titleLabel?.font = UIFont.systemFont(ofSize: self.titleLabel?.font.pointSize ?? 13, weight: .regular)
            self.setTitleColor(.white, for: .normal)
        }
    }
}

extension UIButton {
    func loadImage(with url: URL?, for state: UIControl.State, placeholder: UIImage?) {
        if let url = url {
            self.kf.setImage(with: url, for: state, placeholder: placeholder)
        } else {
            self.setImage(placeholder, for: state)
        }
    }
}

extension UIButton {
    func setUnderlinedTitle(_ title: String, for state: UIControl.State) {
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        self.setAttributedTitle(attributedTitle, for: state)
    }
}

func configureButton(_ button: UIButton, bgColor: String?, titleColor: String? = nil,borderColor: String = "6B85AF") {
    let defaultBgColor = "FFFFFF" // Default background color if bgColor is nil
    let defaultBorderColor = UIColor(borderColor).cgColor
    let defaultTitleColor = "7D95BA"
    button.layer.cornerRadius = iPad ? 35 : 25
    button.layer.borderWidth = 2
    button.layer.borderColor = defaultBorderColor
    if let bgColor = bgColor {
        button.backgroundColor = UIColor(bgColor)
    } else {
        button.backgroundColor = UIColor(defaultBgColor)
    }
    let textColor = titleColor ?? defaultTitleColor
    button.setTitleColor(UIColor(textColor), for: .normal)
    button.titleLabel?.font = UIFont.font1(type: .bold, size: .size14_22)
}

extension UIButton {
    func configureButton(withImageName imageName: String,pointSize: CGFloat = iPad ? 35 : 25, tintColor: UIColor? = appColor,state: UIControl.State = .normal) {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium, scale: .medium)
        let image = UIImage(systemName: imageName, withConfiguration: largeConfig)
        self.setImage(image, for: state)
        self.tintColor = tintColor
    }
}
