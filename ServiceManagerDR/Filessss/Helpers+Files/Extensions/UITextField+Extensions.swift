//
//  UITextField+Extensions.swift
//

import UIKit

extension UITextField {
    
    // Customize UITextField appearance and behavior
    func designTF(placeholder: String? = nil, placeholderColor: UIColor? = .lightGray, underlineColor: UIColor? = .lightGray, underlineSecondaryColor: UIColor? = AppColor.kAppColor, leftImage: UIImage? = nil, isSecure: Bool = false , keyBoardType:UIKeyboardType? = .emailAddress) {
        
        // Add security button if necessary
//        if isSecure {
//            addSecurityButton()
//        }
        
        // Add left image if provided
        if let leftImg = leftImage {
            addCustomImage(image: leftImg)
        }
        
        self.keyboardType = keyBoardType ?? .emailAddress
        
        // Create and add underline view
        let underlineView = UIView()
        underlineView.backgroundColor = underlineColor
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(underlineView)
        
        // Add constraints for the underline view
        NSLayoutConstraint.activate([
            underlineView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: 1.0)
        ])
        
        // Customize placeholder color
        let color = placeholderColor ?? .lightGray
        let placeholderText = placeholder ?? ""
        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor : color])
        
        // Update underline color based on text field state
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if let text = self.text, !text.isEmpty {
                // Text field is not empty, use secondary underline color
                underlineView.backgroundColor = underlineSecondaryColor
            } else {
                // Text field is empty, revert to original underline color
                underlineView.backgroundColor = underlineColor
            }
        }
        
        // Change underline color when text field becomes first responder
        NotificationCenter.default.addObserver(forName: UITextField.textDidBeginEditingNotification, object: self, queue: .main) { _ in
            // Change underline color to indicate focus
            underlineView.backgroundColor = underlineColor
        }
    }
    
    // Add security button to toggle secure text entry
//    func addSecurityButton() {
//        let button = UIButton(type: .custom)
//        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
//        button.addTarget(self, action: #selector(toggleSecurity), for: .touchUpInside)
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
//        button.tintColor = .lightDarkBlueAACCF4
//        rightView = button
//        rightViewMode = .always
//        isSecureTextEntry = true
////        self.setPadding(left: 25, right: 45)
//    }
    
    // Toggle secure text entry

    
    // Add custom image to the text field
    func addCustomImage(direction: ImageDirection = .left, image: UIImage? = UIImage()) {
        let containerSize = CGSize(width: 45, height: 45)
        let container = UIView(frame: CGRect(origin: .zero, size: containerSize))
        
        let imageViewSize = CGSize(width: 20, height: 20)
        let imgRendered = image?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: imgRendered)
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: (containerSize.width - imageViewSize.width) / 2,
                                 y: (containerSize.height - imageViewSize.height) / 2,
                                 width: imageViewSize.width,
                                 height: imageViewSize.height)
        container.addSubview(imageView)
        
        if direction == .left {
            leftViewMode = .always
            leftView = container
        } else {
            rightViewMode = .always
            rightView = container
        }
        borderStyle = .none
        self.tintColor = AppColor.kAppColor
        self.font = UIFont(name: "IBMPlexSans-Medium", size: 15.0)
    }
    
    // Enum to specify image direction
    enum ImageDirection {
        case left
        case right
    }
}

extension UITextField{
    func setPadding(left: CGFloat, right: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
        self.rightView = paddingView2
        self.rightViewMode = .always
    }
    
}

//extension UITextField{
//    func configureTextField(isSafe: Bool = false) {
//        self.layer.borderColor = UIColor.lightDarkBlueAACCF4?.cgColor
//        self.layer.borderWidth = 2
//        self.layer.cornerRadius = iPad ? 35 : 25
//        self.setPadding(left: 25, right: 25)
//        
//        if isSafe{
//            self.setPadding(left: 25, right: 70)
//            let button = UIButton(type: .custom)
//            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
//            button.addTarget(self, action: #selector(toggleSecurity), for: .touchUpInside)
//            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
//            button.tintColor = .lightDarkBlueAACCF4
//            rightView = button
//            rightViewMode = .always
//            isSecureTextEntry = true
//         
//        }
//    }
//    @objc private func toggleSecurity(sender: UIButton) {
//        isSecureTextEntry = !isSecureTextEntry
//        let image = isSecureTextEntry ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")
//        sender.setImage(image, for: .normal)
//    }
//}
//
//extension UITextField {
//    func configureTextField(isSafe: Bool = false) {
//        self.layer.borderColor = UIColor.lightDarkBlueAACCF4?.cgColor
//        self.layer.borderWidth = 2
//        self.layer.cornerRadius = iPad ? 35 : 25
//        self.setPaddingForField(left: 25, right: isSafe ? 70 : 25)
//        
//        if isSafe {
//            let button = UIButton(type: .custom)
//            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
//            button.addTarget(self, action: #selector(toggleSecurity), for: .touchUpInside)
//            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
//            button.tintColor = .lightDarkBlueAACCF4
//            
//            // Container view to hold both the padding and the button
//            let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: self.frame.height))
//            
//            // Add button to the container
//            button.frame = CGRect(x: 25, y: 0, width: 45, height: rightViewContainer.frame.height)
//            rightViewContainer.addSubview(button)
//            
//            self.rightView = rightViewContainer
//            self.rightViewMode = .always
//            self.isSecureTextEntry = true
//        }
//    }
//    
//    @objc private func toggleSecurity(sender: UIButton) {
//        isSecureTextEntry = !isSecureTextEntry
//        let image = isSecureTextEntry ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")
//        sender.setImage(image, for: .normal)
//    }
//    
//    func setPaddingForField(left: CGFloat, right: CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//        
//        // Only set the right padding if `rightView` is not set to a button
//        if !(self.rightView is UIButton) {
//            let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
//            self.rightView = paddingView2
//            self.rightViewMode = .always
//        }
//    }
//}

//
//extension UITextField {
//    func configureTextField(isSafe: Bool = false) {
//        self.layer.borderColor = UIColor.lightDarkBlueAACCF4?.cgColor
//        self.layer.borderWidth = 2
//        self.layer.cornerRadius = iPad ? 35 : 25
//
//        if isSafe {
//            let button = UIButton(type: .custom)
//            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
//            button.addTarget(self, action: #selector(toggleSecurity), for: .touchUpInside)
//            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            button.tintColor = .lightDarkBlueAACCF4
//            
//            // Container view to hold the button
//            let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: self.frame.height))
//            button.frame = CGRect(x: 0, y: 0, width: 40, height: rightViewContainer.frame.height)
//            rightViewContainer.addSubview(button)
//            
//            self.rightView = rightViewContainer
//            self.rightViewMode = .always
//            self.isSecureTextEntry = true
//
//            // Adjust the padding after adding the button
//            self.setPaddingForField(left: 25, right: 40)
//        } else {
//            self.setPaddingForField(left: 25, right: 25)
//        }
//    }
//    
//    @objc private func toggleSecurity(sender: UIButton) {
//        isSecureTextEntry = !isSecureTextEntry
//        let image = isSecureTextEntry ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")
//        sender.setImage(image, for: .normal)
//    }
//    
//    func setPaddingForField(left: CGFloat, right: CGFloat) {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//        
//        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
//        self.rightView = paddingView2
//        self.rightViewMode = .always
//    }
//}

extension UITextField {
    func configureTextField(isSafe: Bool = false) {
        
        self.layer.borderColor = UIColor.lightDarkBlueAACCF4?.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = iPad ? 35 : 25

        // Set the left padding
        self.setPaddingForField(left: 25, right: 0)  // Initially, right padding is 0
        self.font = .font1(size: .size16_25)
        if isSafe {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
            button.addTarget(self, action: #selector(toggleSecurity), for: .touchUpInside)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            button.tintColor = .lightDarkBlueAACCF4
            
            // Container view to hold the button
            let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: self.frame.height))
            button.frame = CGRect(x: 0, y: 0, width: 50, height: rightViewContainer.frame.height)
            rightViewContainer.addSubview(button)
            
            self.rightView = rightViewContainer
            self.rightViewMode = .always
            self.isSecureTextEntry = true
        } else {
            // Set right padding when not secure
            self.setPaddingForField(left: 25, right: 25)
        }
    }
    
    @objc private func toggleSecurity(sender: UIButton) {
        isSecureTextEntry = !isSecureTextEntry
        let image = isSecureTextEntry ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")
        sender.setImage(image, for: .normal)
    }
    
    func setPaddingForField(left: CGFloat, right: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
        // Set right padding only if no custom right view (like the button) is present
        if self.rightView == nil || !isRightViewCustom() {
            let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
            self.rightView = paddingView2
            self.rightViewMode = .always
        }
    }
    
    private func isRightViewCustom() -> Bool {
        return self.rightView is UIButton || self.rightView?.subviews.contains(where: { $0 is UIButton }) == true
    }
}



extension UITextField {
    
    enum Direction {
        case left
        case right
    }
    
    func withImage(direction: Direction = .right, image: UIImage, colorSeparator: UIColor = UIColor("AACCF4"), colorBG: UIColor? = UIColor("CBE9FF"), imgSize: CGFloat) {
        let viewOuter = UIView()
        let viewSeparator = UIView()
        let imgView = UIImageView(image: image)
        
        viewOuter.translatesAutoresizingMaskIntoConstraints = false
        viewSeparator.translatesAutoresizingMaskIntoConstraints = false
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        viewOuter.addSubview(viewSeparator)
        viewOuter.addSubview(imgView)
        let height : CGFloat = iPad ? 70 : 50 // self.frame.size.height
        NSLayoutConstraint.activate([
          
            viewOuter.heightAnchor.constraint(equalToConstant: height),
            viewOuter.widthAnchor.constraint(equalToConstant: height + 5),
            
            imgView.centerXAnchor.constraint(equalTo: viewOuter.centerXAnchor),
            imgView.centerYAnchor.constraint(equalTo: viewOuter.centerYAnchor),
            imgView.heightAnchor.constraint(equalToConstant: imgSize),
            imgView.widthAnchor.constraint(equalToConstant: imgSize),
            
            viewSeparator.topAnchor.constraint(equalTo: viewOuter.topAnchor),
            viewSeparator.bottomAnchor.constraint(equalTo: viewOuter.bottomAnchor),
            viewSeparator.widthAnchor.constraint(equalToConstant: 3)
        ])
        
        if direction == .left {
            viewSeparator.trailingAnchor.constraint(equalTo: viewOuter.trailingAnchor).isActive = true
            viewSeparator.leadingAnchor.constraint(equalTo: imgView.trailingAnchor, constant: 5).isActive = true
        } else {
            viewSeparator.leadingAnchor.constraint(equalTo: viewOuter.leadingAnchor).isActive = true
            viewSeparator.trailingAnchor.constraint(equalTo: imgView.leadingAnchor, constant: -5).isActive = true
        }
        
        viewSeparator.backgroundColor = colorSeparator
        viewOuter.backgroundColor = colorBG
        imgView.contentMode = .scaleAspectFit
        self.clipsToBounds = true
        if direction == .left {
            self.leftViewMode = .always
            self.leftView = viewOuter
        } else {
            self.rightViewMode = .always
            self.rightView = viewOuter
        }
    }
}

extension UITextField{
    func isEmpty() -> Bool{
        if self.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true{
            return true
        }else{
            return false
        }
    }
}
